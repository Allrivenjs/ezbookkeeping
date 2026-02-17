# Usuarios y permisos en ezBookkeeping

## Estructura de usuarios

- **No hay roles** (admin, usuario, etc.). Todos los usuarios son del mismo tipo.
- Cada usuario tiene: `username`, `email`, `nickname`, `password`, moneda por defecto, preferencias de formato y **restricciones de funcionalidad** (ver abajo).

## Cómo configurar usuario y contraseña antes de iniciar

### 1. Configuración en `conf/ezbookkeeping.ini`

En la sección `[user]`:

- **`enable_register`**: si es `true`, cualquiera puede registrarse desde la web. Si es `false`, solo existirán los usuarios que crees tú (por CLI o por variables de entorno).
- **`default_feature_restrictions`**: restricciones por defecto para nuevos usuarios (lista de números separados por comas, ver tabla más abajo). Dejar vacío = sin restricciones.

Ejemplo para que solo tú crees usuarios y el primero tenga todas las capacidades:

```ini
[user]
enable_register = false
default_feature_restrictions =
```

### 2. Crear el primer usuario por CLI (después del primer arranque)

Con el servidor parado (o en otro terminal contra la misma instalación):

```bash
./ezbookkeeping userdata user-add \
  --username admin \
  --email admin@ejemplo.com \
  --nickname "Administrador" \
  --password "TuPasswordSeguro" \
  --default-currency USD
```

En Docker, ejecutando dentro del contenedor del backend:

```bash
docker compose exec backend /ezbookkeeping/ezbookkeeping userdata user-add \
  --username admin --email admin@ejemplo.com --nickname "Admin" \
  --password "TuPasswordSeguro" --default-currency USD
```

### 3. Crear usuario inicial por variables de entorno (Docker)

Si usas el `docker-compose` con el entrypoint actualizado, puedes definir un usuario inicial que se crea **al arrancar** el contenedor (solo si aún no existe):

- `EBK_INIT_ADMIN_USERNAME`: nombre de usuario (obligatorio para crear).
- `EBK_INIT_ADMIN_PASSWORD`: contraseña (obligatorio para crear).
- `EBK_INIT_ADMIN_EMAIL`: email (obligatorio para crear).
- `EBK_INIT_ADMIN_NICKNAME`: nombre para mostrar (opcional; por defecto = username).
- `EBK_INIT_ADMIN_DEFAULT_CURRENCY`: moneda por defecto (opcional; por defecto = USD).

Ese usuario recibe las restricciones definidas en `default_feature_restrictions` del `conf/ezbookkeeping.ini`.

---

## Restricciones de funcionalidad (permisos)

No hay “roles”, sino **restricciones por funcionalidad**. Si una restricción está **activa** para un usuario, **no puede** usar esa función.

| Nº | Clave (para CLI) | Descripción |
|----|-------------------|-------------|
| 1  | Update Password | Cambiar contraseña |
| 2  | Update Email | Cambiar email |
| 3  | Update Profile Basic Info | Editar perfil básico |
| 4  | Update Avatar | Cambiar avatar |
| 5  | Logout Other Session | Cerrar otras sesiones |
| 6  | Enable Two-Factor Authentication | Activar 2FA |
| 7  | Disable Two-Factor Authentication | Desactivar 2FA |
| 8  | Forget Password | Recuperar contraseña |
| 9  | Import Transactions | Importar transacciones |
| 10 | Export Transactions | Exportar transacciones |
| 11 | Clear All Data | Borrar todos los datos |
| 12 | Sync Application Settings | Sincronizar ajustes |
| 13 | MCP Access | Acceso MCP (IA) |
| 14 | Create Transaction from AI Image Recognition | Crear transacción desde imagen (IA) |
| 15 | OAuth 2.0 Login | Inicio de sesión OAuth2 |
| 16 | Unlink Third-Party Login | Desvincular login externo |
| 17 | Generate API Token | Generar token de API |

- **Sin restricciones**: el usuario puede hacer todo lo anterior (equivalente a “usuario completo”).
- **Con restricciones**: en `default_feature_restrictions` o vía CLI pones los números (ej: `1,2,9,10`) para **restringir** esas funciones a los nuevos usuarios. Luego puedes ajustar por usuario con los comandos de la CLI.

### Ejemplos por CLI (sobre usuario ya creado)

```bash
# Ver usuario
./ezbookkeeping userdata user-get --username admin

# Establecer restricciones (sustituye las actuales)
./ezbookkeeping userdata user-set-restrict-features --username admin --features "9,10,11"

# Añadir restricciones
./ezbookkeeping userdata user-add-restrict-features --username admin --features "13,14"

# Quitar restricciones
./ezbookkeeping userdata user-remove-restrict-features --username admin --features "9,10"
```

---

## Resumen rápido

| Objetivo | Dónde |
|----------|--------|
| Evitar auto-registro en la web | `conf/ezbookkeeping.ini` → `[user]` → `enable_register = false` |
| Restricciones por defecto para nuevos usuarios | `[user]` → `default_feature_restrictions = 9,10,11` (ejemplo) |
| Crear usuario antes/después de iniciar (binario) | CLI: `userdata user-add --username ... --password ...` |
| Crear usuario al iniciar con Docker | Variables `EBK_INIT_ADMIN_*` en `docker-compose` + entrypoint que ejecuta `userdata user-add` si no existe el usuario |
