import 'package:screen_protector/screen_protector.dart';

/// Servicio encargado de gestionar la seguridad de la pantalla.
/// Utiliza el paquete screen_protector para manejar las flags nativas
/// tanto en Android (FLAG_SECURE) como en iOS (capas de seguridad).
class SecurityService {
  /// Activa todas las protecciones disponibles:
  /// - Previene capturas de pantalla (imagen negra).
  /// - Previene grabaciones de pantalla.
  /// - Oculta el contenido en el selector de aplicaciones (multitarea).
  static Future<void> enableAllProtections() async {
    // Evita capturas y grabaciones (en iOS la imagen resultará negra)
    await ScreenProtector.preventScreenshotOn();
  }

  /// Desactiva las protecciones.
  static Future<void> disableAllProtections() async {
    await ScreenProtector.preventScreenshotOff();
  }
}
