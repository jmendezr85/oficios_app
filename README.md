# 📱 Oficios App

Aplicación móvil desarrollada en **Flutter** que conecta a clientes con profesionales de oficios (carpinteros, electricistas, mecánicos, etc.).  
Inspirada en la dinámica de **inDriver**, pero orientada a servicios profesionales locales.

---

## 🚀 Características principales

- **Selección de rol** al inicio (Cliente / Profesional).
- **Registro y autenticación** de usuarios.
- **Listado de profesionales** con tarjetas limpias y puntuación.
- **Detalle de servicio** con formulario de solicitud.
- **Sistema de solicitudes** (crear, listar, cambiar estado).
- **Base de datos local** con SQLite (persistencia).
- **Interfaz moderna** con Material 3 y paleta amarilla vibrante.

---

## 📸 Capturas de pantalla (mockups)

_(Puedes reemplazar estas imágenes cuando tengas screenshots reales de la app en tu emulador/dispositivo)_

![Pantalla de selección de rol](docs/screenshots/role_selector.png)  
![Listado de profesionales](docs/screenshots/pro_list.png)  
![Formulario de solicitud](docs/screenshots/request_form.png)

---

## 🛠️ Tecnologías utilizadas

- [Flutter](https://flutter.dev) 3.x
- [Dart](https://dart.dev)
- [Riverpod](https://riverpod.dev) para gestión de estado
- [SQLite](https://pub.dev/packages/sqflite) para persistencia local
- [Uuid](https://pub.dev/packages/uuid) para generar identificadores únicos

---

## ⚙️ Instalación y ejecución

### 1. Clonar el repositorio

```bash
git clone https://github.com/TU_USUARIO/oficios_app.git
cd oficios_app
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Ejecutar en un dispositivo/emulador

```bash
flutter run
```

---

## 📂 Estructura de carpetas

```
lib/
│── main.dart
│── src/
    ├── features/
    │   ├── auth/          # Login y registro
    │   ├── home/          # Pantalla principal
    │   ├── onboarding/    # Selección de rol
    │   ├── pro/           # Profesionales (servicios)
    │   ├── requests/      # Solicitudes de trabajo
    │   └── search/        # Listado y búsqueda
    └── theme/             # Colores y estilos globales
```

---

## 👨‍💻 Autor

Desarrollado por [TU NOMBRE](https://github.com/TU_USUARIO) con ❤️ en Flutter.

---

## 📌 Próximas mejoras

- Sistema de **reseñas y calificaciones** para profesionales.
- Integración con **mapas** para localizar servicios cercanos.
- Notificaciones push para nuevas solicitudes.
- Backend remoto para sincronizar múltiples usuarios.
