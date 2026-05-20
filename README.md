# Práctica: Protección contra Fuga de Información (Prevención de Capturas de Pantalla)

Este proyecto es una aplicación móvil desarrollada en Flutter para demostrar la implementación de medidas de seguridad nativas para prevenir la fuga de información sensible a través de capturas de pantalla o grabaciones de pantalla en Android.

## 🛡️ Objetivo de la Práctica
El objetivo principal es asegurar la pantalla de inicio de sesión (Login) de una aplicación, impidiendo que el sistema operativo permita realizar capturas de pantalla o que el contenido sea visible en el selector de aplicaciones recientes (multitarea).

## 🚀 Características
- **Interfaz Moderna**: Diseño limpio usando Material 3.
- **Seguridad Nativa**: Implementación de `FLAG_SECURE` mediante Platform Channels.
- **Validación de Formularios**: Validación básica de campos de correo y contraseña.
- **Arquitectura Limpia**: Separación de lógica de seguridad y vistas.

## 🛠️ Tecnologías Usadas
- **Flutter**: SDK de desarrollo multiplataforma.
- **Dart**: Lenguaje de programación.
- **Kotlin**: Para la implementación de seguridad nativa en Android.

## 📂 Estructura del Proyecto
- `lib/services/security_service.dart`: Servicio Flutter para llamar al código nativo.
- `lib/screens/login_screen.dart`: Pantalla de Login con protección activada.
- `android/app/src/main/kotlin/.../MainActivity.kt`: Configuración de `FLAG_SECURE` en la ventana de Android.

## ⚙️ Cómo Ejecutar el Proyecto
1. **Requisitos**: Tener instalado Flutter y Android Studio.
2. **Clonar/Abrir**: Abre el proyecto en tu IDE preferido.
3. **Obtener dependencias**:
   ```bash
   flutter pub get
   ```
4. **Ejecutar**:
   ```bash
   flutter run
   ```

## 📸 Guía para Pruebas y Evidencia
Para el reporte académico, sigue estos pasos:

1. **Prueba de Captura**:
   - Intenta tomar una captura de pantalla (`Botón Encendido + Vol Bajar`).
   - **Resultado Esperado**: El sistema mostrará un mensaje indicando que la aplicación no lo permite, o la captura resultará en una imagen completamente negra.
2. **Prueba de Multitarea**:
   - Abre el menú de aplicaciones recientes.
   - **Resultado Esperado**: La previsualización de la aplicación debe aparecer en blanco o negro, ocultando las credenciales.
3. **Evidencia para el PDF**:
   - Foto del mensaje de error al intentar la captura (usar otro teléfono para tomar la foto si es posible, o capturar la notificación del sistema).
   - Screenshot del menú de "Recientes" donde se vea la pantalla bloqueada.

## 📝 Explicación de Seguridad
La protección se logra mediante el uso de `WindowManager.LayoutParams.FLAG_SECURE` en Android. Esta bandera indica al sistema que el contenido de la ventana debe tratarse como seguro, impidiendo que aparezca en capturas de pantalla o que sea visualizado en pantallas no seguras.

---
**Desarrollado para:** Práctica Académica de Seguridad Móvil.
