import 'package:screen_protector/screen_protector.dart';
import 'package:trust_location/trust_location.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';

/// Servicio experto de seguridad integral con monitoreo constante.
class SecurityService {
  
  /// Activa protecciones contra capturas de pantalla (MASVS-PLATFORM-3).
  static Future<void> enableAllProtections() async {
    try {
      await ScreenProtector.preventScreenshotOn();
    } catch (_) {}
  }

  /// Libera protecciones de pantalla.
  static Future<void> disableAllProtections() async {
    try {
      await ScreenProtector.preventScreenshotOff();
    } catch (_) {}
  }

  /// Verifica permisos de ubicación de forma silenciosa para monitoreo en tiempo real.
  static Future<bool> hasLocationPermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return (permission == LocationPermission.always || permission == LocationPermission.whileInUse);
    } catch (e) {
      return false;
    }
  }

  /// DETECCIÓN DE FAKE GPS EN TIEMPO REAL
  /// Consulta la API nativa para saber si la ubicación actual es simulada.
  static Future<bool> isUsingFakeGps() async {
    // En iOS, el sistema no permite que apps de terceros detecten Mock Locations de otras apps.
    // La protección en iOS se enfoca en Anti-Screenshot.
    if (Platform.isIOS) return false;

    try {
      // trust_location interroga directamente al MockProvider de Android.
      return await TrustLocation.isMockLocation;
    } catch (e) {
      return false;
    }
  }
}
