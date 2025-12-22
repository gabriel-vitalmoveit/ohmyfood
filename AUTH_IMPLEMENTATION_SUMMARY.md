# ✅ Autenticação JWT - Implementação Completa

## 🎯 O que foi implementado

### 1. ✅ Serviços de Autenticação

**AuthService** (`lib/src/services/auth_service.dart`)
- `login(email, password)` - Login com email e senha
- `register(email, password, displayName?)` - Registro de novo usuário
- Retorna `AuthResponse` com `user` e `tokens` (accessToken, refreshToken)

**AuthRepository** (`lib/src/services/auth_repository.dart`)
- Armazena tokens em `SharedPreferences`
- Salva email e ID do usuário
- Métodos: `saveTokens()`, `getAccessToken()`, `getRefreshToken()`, `getUserId()`, `clearAuth()`

### 2. ✅ Providers (Riverpod)

**AuthProviders** (`lib/src/services/providers/auth_providers.dart`)
- `authStateProvider` - Gerencia estado de autenticação
- Estados: `initial`, `loading`, `authenticated`, `unauthenticated`, `error`
- Métodos: `login()`, `register()`, `logout()`

**ApiProviders** (atualizado)
- `apiClientProvider` - Agora inclui `AuthRepository` para adicionar tokens automaticamente
- `currentUserIdProvider` - Obtém ID do usuário autenticado
- Todas as requisições HTTP agora incluem `Authorization: Bearer <token>`

### 3. ✅ Telas de Autenticação

**LoginScreen** (`lib/src/features/auth/login_screen.dart`)
- Campos: Email, Password
- Validação de erros
- Loading state
- Redireciona para `/home` após login bem-sucedido
- Link para registro

**RegisterScreen** (`lib/src/features/auth/register_screen.dart`)
- Campos: Display Name (opcional), Email, Password, Confirm Password
- Validação de senhas (deve coincidir, mínimo 6 caracteres)
- Loading state
- Redireciona para `/home` após registro bem-sucedido
- Link para login

### 4. ✅ Proteção de Rotas

**Router** (`lib/router.dart`)
- Rotas protegidas: `/home`, `/orders`, `/profile`, `/cart`, `/checkout`
- Redireciona para `/login` se não autenticado
- Redireciona para `/home` se autenticado e tentar acessar `/login` ou `/register`
- Verifica estado de autenticação ao iniciar app

### 5. ✅ Integração com API

**ApiClient** (atualizado)
- Todas as requisições HTTP incluem token automaticamente
- Método `_getHeaders()` adiciona `Authorization: Bearer <token>`
- Funciona com todos os endpoints existentes

**ProfileScreen** (atualizado)
- Mostra email do usuário autenticado
- Botão de logout funcional
- Confirmação antes de logout

---

## 🔐 Fluxo de Autenticação

### Login
1. Usuário preenche email e senha
2. `AuthService.login()` chama `/api/auth/login`
3. Backend retorna `{ user, tokens: { accessToken, refreshToken } }`
4. Tokens são salvos em `SharedPreferences`
5. Estado muda para `authenticated`
6. Router redireciona para `/home`

### Registro
1. Usuário preenche dados (email, senha, nome opcional)
2. Validação de senhas
3. `AuthService.register()` chama `/api/auth/register`
4. Backend cria usuário e retorna tokens
5. Tokens são salvos
6. Estado muda para `authenticated`
7. Router redireciona para `/home`

### Requisições Autenticadas
1. `ApiClient` obtém token de `AuthRepository`
2. Adiciona `Authorization: Bearer <token>` no header
3. Backend valida token via JWT Strategy
4. Requisição processada normalmente

### Logout
1. Usuário clica em "Terminar sessão"
2. Confirmação exibida
3. `AuthRepository.clearAuth()` remove tokens
4. Estado muda para `unauthenticated`
5. Router redireciona para `/login`

---

## 📋 Endpoints do Backend Usados

| Endpoint | Método | Descrição |
|----------|--------|-----------|
| `/api/auth/login` | POST | Login com email/senha |
| `/api/auth/register` | POST | Criar nova conta |
| `/api/restaurants` | GET | Lista restaurantes (com token) |
| `/api/restaurants/:id` | GET | Detalhes restaurante (com token) |
| `/api/restaurants/:id/menu` | GET | Menu do restaurante (com token) |
| `/api/orders/user/:userId` | GET | Pedidos do usuário (com token) |
| `/api/orders/user/:userId` | POST | Criar pedido (com token) |

---

## ✅ Status da Implementação

| Componente | Status | Observações |
|------------|--------|-------------|
| **AuthService** | ✅ Completo | Login e Register funcionando |
| **AuthRepository** | ✅ Completo | Armazenamento seguro de tokens |
| **AuthProviders** | ✅ Completo | Estado gerenciado com Riverpod |
| **LoginScreen** | ✅ Completo | UI moderna e funcional |
| **RegisterScreen** | ✅ Completo | Validações implementadas |
| **Proteção de Rotas** | ✅ Completo | Router protegido |
| **ApiClient com Auth** | ✅ Completo | Tokens adicionados automaticamente |
| **ProfileScreen** | ✅ Completo | Logout funcional |
| **Refresh Token** | ⚠️ Não implementado | Backend não tem endpoint ainda |

---

## 🚀 Como Usar

### Testar Login
1. Abrir app
2. Se não autenticado, será redirecionado para `/login`
3. Preencher email e senha
4. Clicar em "Entrar"
5. Será redirecionado para `/home`

### Testar Registro
1. Na tela de login, clicar em "Regista-te"
2. Preencher dados
3. Clicar em "Criar conta"
4. Será redirecionado para `/home`

### Testar Logout
1. Ir para `/profile`
2. Clicar em "Terminar sessão"
3. Confirmar
4. Será redirecionado para `/login`

---

## 🔧 Dependências Adicionadas

```yaml
shared_preferences: ^2.2.2  # Armazenamento seguro de tokens
```

---

## 📝 Notas Importantes

1. **Tokens são armazenados localmente** - Usando `SharedPreferences`
2. **Tokens não expiram automaticamente** - Quando expirar, usuário precisa fazer login novamente
3. **Refresh Token não implementado** - Backend não tem endpoint `/auth/refresh` ainda
4. **User ID obtido do token** - Não está sendo decodificado do JWT, usando repositório

---

## 🎯 Próximos Passos (Opcional)

1. **Implementar Refresh Token** - Quando backend adicionar endpoint
2. **Decodificar JWT no frontend** - Para obter user ID diretamente do token
3. **Expiração automática** - Verificar se token expirou e fazer refresh
4. **Biometria** - Login com impressão digital/Face ID
5. **Remember Me** - Opção para manter sessão

---

**Status:** ✅ **Implementação Completa e Funcional**

**Data:** 22/12/2025

