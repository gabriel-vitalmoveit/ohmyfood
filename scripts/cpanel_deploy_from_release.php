<?php
/**
 * cPanel auto-deploy (pull-based) from GitHub Releases.
 *
 * ✅ Robust for shared hosting: no inbound FTP/SFTP needed.
 * Run via Cron (recommended) or via a small webhook wrapper.
 *
 * Requirements on cPanel:
 * - PHP CLI with ZipArchive enabled
 * - Outbound HTTPS allowed (to github.com / api.github.com)
 *
 * Environment variables:
 * - GITHUB_REPO (required) e.g. "gabriel-vitalmoveit/ohmyfood"
 * - GITHUB_TOKEN (optional) GitHub token if repo is private
 * - DEPLOY_TARGET (optional) "courier" | "restaurant" | "customer"
 * - RELEASE_TAG (optional) deploy a specific tag, e.g. "web-build-20251229-235959"
 * - ASSET_PREFIX (optional if DEPLOY_TARGET provided) e.g. "estafeta.ohmyfood.eu" / "restaurante.ohmyfood.eu" / "ohmyfood.eu"
 * - DOCROOT (optional if running from public_html and DEPLOY_TARGET provided) e.g. "/home/<cpanel_user>/public_html/estafeta.ohmyfood.eu"
 * - KEEP_BACKUPS (optional) default 3
 * - DEPLOY_ROOT (optional) directory for backups/workdir (recommended outside public_html)
 *
 * Usage example:
 *   GITHUB_REPO="gabriel-vitalmoveit/ohmyfood" \
 *   ASSET_PREFIX="estafeta.ohmyfood.eu" \
 *   DOCROOT="/home/user/public_html/estafeta.ohmyfood.eu" \
 *   php -d detect_unicode=0 scripts/cpanel_deploy_from_release.php
 */

function envOrNull(string $key): ?string {
  $v = getenv($key);
  if ($v === false) return null;
  $v = trim($v);
  return $v === '' ? null : $v;
}

function fail(string $msg, int $code = 1): void {
  fwrite(STDERR, "ERROR: $msg\n");
  exit($code);
}

function info(string $msg): void {
  fwrite(STDOUT, "$msg\n");
}

function httpGetJson(string $url, ?string $token): array {
  $headers = [
    "User-Agent: ohmyfood-cpanel-deployer",
    "Accept: application/vnd.github+json",
  ];
  if ($token) $headers[] = "Authorization: Bearer $token";

  $ctx = stream_context_create([
    "http" => [
      "method" => "GET",
      "header" => implode("\r\n", $headers),
      "timeout" => 60,
    ],
  ]);
  $raw = @file_get_contents($url, false, $ctx);
  if ($raw === false) {
    $err = error_get_last();
    fail("Failed to GET $url" . ($err ? (": " . $err["message"]) : ""));
  }
  $data = json_decode($raw, true);
  if (!is_array($data)) fail("Invalid JSON from $url");
  return $data;
}

function downloadFile(string $url, string $dest, ?string $token): void {
  $headers = [
    "User-Agent: ohmyfood-cpanel-deployer",
    "Accept: application/octet-stream",
  ];
  if ($token) $headers[] = "Authorization: Bearer $token";

  $ctx = stream_context_create([
    "http" => [
      "method" => "GET",
      "header" => implode("\r\n", $headers),
      "timeout" => 300,
    ],
  ]);

  $in = @fopen($url, "rb", false, $ctx);
  if (!$in) {
    $err = error_get_last();
    fail("Failed to download $url" . ($err ? (": " . $err["message"]) : ""));
  }
  $out = @fopen($dest, "wb");
  if (!$out) fail("Failed to write $dest");

  stream_copy_to_stream($in, $out);
  fclose($in);
  fclose($out);
}

function rrmdir(string $dir): void {
  if (!is_dir($dir)) return;
  $items = new RecursiveIteratorIterator(
    new RecursiveDirectoryIterator($dir, RecursiveDirectoryIterator::SKIP_DOTS),
    RecursiveIteratorIterator::CHILD_FIRST
  );
  foreach ($items as $item) {
    if ($item->isDir()) @rmdir($item->getPathname());
    else @unlink($item->getPathname());
  }
  @rmdir($dir);
}

function ensureDir(string $dir): void {
  if (is_dir($dir)) return;
  if (!@mkdir($dir, 0755, true)) fail("Failed to create dir: $dir");
}

function listDirsSortedByMtime(string $parent, string $prefix): array {
  $out = [];
  if (!is_dir($parent)) return $out;
  foreach (scandir($parent) as $name) {
    if ($name === "." || $name === "..") continue;
    if (strpos($name, $prefix) !== 0) continue;
    $path = rtrim($parent, "/") . "/" . $name;
    if (is_dir($path)) $out[] = $path;
  }
  usort($out, function($a, $b) { return filemtime($b) <=> filemtime($a); });
  return $out;
}

$repo = envOrNull("GITHUB_REPO") ?? fail("Missing env: GITHUB_REPO");
$token = envOrNull("GITHUB_TOKEN");
$deployTarget = envOrNull("DEPLOY_TARGET"); // courier|restaurant|customer
$tag = envOrNull("RELEASE_TAG"); // optional
$assetPrefix = envOrNull("ASSET_PREFIX");
$docroot = envOrNull("DOCROOT");
$keepBackups = intval(envOrNull("KEEP_BACKUPS") ?? "3");
if ($keepBackups < 0) $keepBackups = 0;

if (!class_exists("ZipArchive")) {
  fail("ZipArchive not available in PHP. Enable the zip extension in cPanel.");
}

$targetMap = [
  "courier" => "estafeta.ohmyfood.eu",
  "restaurant" => "restaurante.ohmyfood.eu",
  "customer" => "ohmyfood.eu",
];

if ($deployTarget && isset($targetMap[$deployTarget])) {
  $assetPrefix = $assetPrefix ?? $targetMap[$deployTarget];

  // If DOCROOT not provided, infer it from current working directory.
  // Intended cron usage: cd /home/<user>/public_html && php scripts/cpanel_deploy_from_release.php
  if (!$docroot) {
    $cwd = getcwd();
    if ($cwd && basename($cwd) === "public_html") {
      $docroot = rtrim($cwd, "/") . "/" . $assetPrefix;
    }
  }
}

if (!$assetPrefix) fail("Missing env: ASSET_PREFIX (or set DEPLOY_TARGET=courier|restaurant|customer)");
if (!$docroot) fail("Missing env: DOCROOT (or run from public_html with DEPLOY_TARGET)");

$apiBase = "https://api.github.com/repos/$repo";

info("Repo: $repo");
info("Docroot: $docroot");
info("Asset prefix: $assetPrefix");
info("Target tag: " . ($tag ?? "(latest web-build-*)"));

// Find release
$release = null;
if ($tag) {
  $release = httpGetJson("$apiBase/releases/tags/" . rawurlencode($tag), $token);
} else {
  // Prefer the most recent release whose tag starts with "web-build-"
  $releases = httpGetJson("$apiBase/releases?per_page=10", $token);
  foreach ($releases as $r) {
    if (is_array($r) && isset($r["tag_name"]) && strpos($r["tag_name"], "web-build-") === 0) {
      $release = $r;
      break;
    }
  }
  if (!$release) fail("No web-build-* release found.");
}

$tagName = $release["tag_name"] ?? "(unknown)";
info("Using release: $tagName");

// Pick asset by prefix
$assets = $release["assets"] ?? [];
$asset = null;
foreach ($assets as $a) {
  $name = $a["name"] ?? "";
  if (strpos($name, $assetPrefix . "_web_") === 0 && substr($name, -4) === ".zip") {
    $asset = $a;
    break;
  }
}
if (!$asset) fail("No asset found for prefix '$assetPrefix' in release '$tagName'.");

$downloadUrl = $asset["browser_download_url"] ?? null;
if (!$downloadUrl) fail("Missing browser_download_url for asset");

$stamp = gmdate("Ymd-His");
$deployRoot = envOrNull("DEPLOY_ROOT");
if (!$deployRoot) {
  // Prefer a directory outside public_html when possible.
  // If DOCROOT is /home/<user>/public_html/<site>, store in /home/<user>/deploy/
  $doc = rtrim($docroot, "/");
  if (strpos($doc, "/public_html/") !== false) {
    $home = dirname(dirname($doc)); // /home/<user>
    $deployRoot = rtrim($home, "/") . "/deploy";
  } else {
    // fallback: sibling hidden folder
    $deployRoot = dirname($doc) . "/.deploy";
  }
}

ensureDir($deployRoot);

$workDir = rtrim($deployRoot, "/") . "/work_" . $assetPrefix . "_" . $stamp;
$newDir = $workDir . "/new";
$zipPath = $workDir . "/asset.zip";
$backupDir = rtrim($deployRoot, "/") . "/backup_" . $assetPrefix . "_" . $stamp;

ensureDir($workDir);
ensureDir($newDir);

info("Downloading asset...");
downloadFile($downloadUrl, $zipPath, $token);
info("Downloaded to: $zipPath (" . filesize($zipPath) . " bytes)");

info("Extracting...");
$zip = new ZipArchive();
if ($zip->open($zipPath) !== true) fail("Failed to open zip: $zipPath");
if (!$zip->extractTo($newDir)) fail("Failed to extract zip to $newDir");
$zip->close();

// Quick sanity: require index.html
if (!file_exists($newDir . "/index.html")) {
  fail("Extracted build missing index.html. Aborting.");
}

// Swap deploy (rename is atomic if same filesystem)
info("Deploying (atomic swap)...");
if (!is_dir($docroot)) {
  // First deploy: just move new to docroot
  if (!@rename($newDir, $docroot)) fail("Failed to move new build into docroot: $docroot");
} else {
  // Backup old
  if (!@rename($docroot, $backupDir)) fail("Failed to backup current docroot to $backupDir");
  if (!@rename($newDir, $docroot)) {
    // rollback
    @rename($backupDir, $docroot);
    fail("Failed to move new build into docroot: $docroot (rolled back)");
  }
}

info("✅ Deployed $assetPrefix from $tagName");

// Cleanup workdir
rrmdir($workDir);

// Prune backups
if ($keepBackups >= 0) {
  $backups = listDirsSortedByMtime($deployRoot, "backup_" . $assetPrefix . "_");
  for ($i = $keepBackups; $i < count($backups); $i++) {
    rrmdir($backups[$i]);
  }
}

info("Done.");

