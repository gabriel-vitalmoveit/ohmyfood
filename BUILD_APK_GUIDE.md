# 📱 Guia de Build APK - OhMyFood

## ⏱️ Tempo Esperado

- **Primeira vez:** 10-15 minutos (baixa dependências Gradle, compila tudo)
- **Builds subsequentes:** 3-5 minutos (apenas recompilação)

## 🚀 Build Rápido (Debug - Para Testes)

Se quiser testar rapidamente sem otimizações:

```bash
cd apps/customer_app
flutter build apk --debug
```

**Tempo:** 2-3 minutos
**Localização:** `build/app/outputs/flutter-apk/app-debug.apk`

## 📦 Build de Produção (Release)

### Customer App

```bash
cd apps/customer_app
flutter clean
flutter pub get
flutter build apk --release \
  --dart-define=ENV=prod \
  --dart-define=API_BASE_URL=https://seu-backend.up.railway.app/api
```

**Tempo:** 5-10 minutos
**Localização:** `build/app/outputs/flutter-apk/app-release.apk`

### Courier App

```bash
cd apps/courier_app
flutter clean
flutter pub get
flutter build apk --release \
  --dart-define=ENV=prod \
  --dart-define=API_BASE_URL=https://seu-backend.up.railway.app/api
```

## 🔧 Otimizações

### 1. Usar Script Automatizado

```powershell
# Windows
.\scripts\build-mobile.ps1 https://seu-backend.up.railway.app customer_app android
```

### 2. Build Split APK (Menor tamanho)

```bash
flutter build apk --split-per-abi --release
```

Gera 3 APKs separados (arm64-v8a, armeabi-v7a, x86_64) - cada um menor.

### 3. Build App Bundle (Para Google Play)

```bash
flutter build appbundle --release
```

## ⚠️ Problemas Comuns

### Build muito lento

**Causa:** Primeira vez ou cache corrompido

**Solução:**
```bash
flutter clean
flutter pub get
# Limpar cache do Gradle (opcional)
cd android
./gradlew clean
cd ..
flutter build apk --release
```

### Erro de memória

**Solução:** Aumentar memória do Gradle

Edite `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=1024m
```

### Erro "Gradle sync failed"

**Solução:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

## 📊 Tamanhos Esperados

- **Debug APK:** ~50-80 MB
- **Release APK:** ~20-30 MB
- **Split APK (por arquitetura):** ~8-12 MB cada

## ✅ Verificação

Após o build, verifique:

1. **APK gerado:**
   ```bash
   ls -lh build/app/outputs/flutter-apk/app-release.apk
   ```

2. **Instalar no dispositivo:**
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

3. **Testar:**
   - Abrir app
   - Verificar se conecta à API
   - Testar funcionalidades principais

## 🎯 Próximos Passos

Após gerar o APK:

1. **Testar em dispositivo real**
2. **Verificar conexão com API Railway**
3. **Testar funcionalidades principais**
4. **Assinar APK para produção** (se necessário)
5. **Publicar na Google Play Store** (quando pronto)

---

**Dica:** O primeiro build sempre demora mais. Builds subsequentes são muito mais rápidos!

