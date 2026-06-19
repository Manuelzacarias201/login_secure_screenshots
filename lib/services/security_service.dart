import 'package:screen_protector/screen_protector.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:flutter/services.dart';

/// Servicio de seguridad integral avanzado utilizando geolocator moderno.
class SecurityService {
  static const _storage = FlutterSecureStorage();
  static const _platform = MethodChannel('com.example.practicalogin/security');

  // Campos sensibles definidos
  static const String keyApiKey = 'api_key';
  static const String keySessionToken = 'session_token';
  static const String keyUserPrivateId = 'user_private_id';
  static const String keyCreditCardMask = 'credit_card_mask';

  // Controlador para notificar a la UI que los datos cambiaron
  static final _dataUpdateController = StreamController<void>.broadcast();
  static Stream<void> get onDataUpdate => _dataUpdateController.stream;

  /// Inicializa datos sensibles si no existen.
  static Future<void> initSensitiveData() async {
    final existing = await _storage.read(key: keyApiKey);
    if (existing == null) {
      await _storage.write(key: keyApiKey, value: 'sk_live_51MhX8YEj9k0P2... (Confidencial)');
      await _storage.write(key: keySessionToken, value: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');
      await _storage.write(key: keyUserPrivateId, value: 'UUID-9988-7766-5544-3322');
      await _storage.write(key: keyCreditCardMask, value: '**** **** **** 4242');
      _dataUpdateController.add(null); // Notificar cambio
      print("INFO: Datos sensibles inicializados en Secure Storage.");
    }
  }

  /// Fuerza la escritura/actualización de los datos (útil para recargar)
  static Future<void> forceUpdateData() async {
    await _storage.write(key: keyApiKey, value: 'sk_live_51MhX8YEj9k0P2... (Confidencial)');
    await _storage.write(key: keySessionToken, value: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');
    await _storage.write(key: keyUserPrivateId, value: 'UUID-9988-7766-5544-3322');
    await _storage.write(key: keyCreditCardMask, value: '**** **** **** 4242');
    _dataUpdateController.add(null); // Notificar cambio
    print("INFO: Datos actualizados/recargados forzosamente.");
  }

  /// Elimina el contenido de los datos sensibles.
  static Future<void> wipeSensitiveData() async {
    await _storage.delete(key: keyApiKey);
    await _storage.delete(key: keySessionToken);
    await _storage.delete(key: keyUserPrivateId);
    await _storage.delete(key: keyCreditCardMask);
    _dataUpdateController.add(null); // Notificar cambio
    print("WARNING: ¡DATOS SENSIBLES ELIMINADOS POR ACCIÓN REMOTA!");
  }

  /// Obtiene todos los datos sensibles actuales para mostrarlos en la UI.
  static Future<Map<String, String?>> getAllSensitiveData() async {
    return {
      'API Key': await _storage.read(key: keyApiKey),
      'Session Token': await _storage.read(key: keySessionToken),
      'Private ID': await _storage.read(key: keyUserPrivateId),
      'Credit Card': await _storage.read(key: keyCreditCardMask),
    };
  }
  
  /// Activa FLAG_SECURE en Android y Capas de Seguridad en iOS.
  static Future<void> enableAllProtections() async {
    try {
      await ScreenProtector.preventScreenshotOn();
    } catch (_) {}
  }

  /// Libera las protecciones de pantalla.
  static Future<void> disableAllProtections() async {
    try {
      await ScreenProtector.preventScreenshotOff();
    } catch (_) {}
  }

  /// Verifica y solicita permisos de ubicación de forma que aparezcan en Configuración.
  static Future<bool> hasLocationPermissions() async {
    try {
      var status = await Permission.location.status;
      if (status.isDenied) {
        status = await Permission.location.request();
      }
      
      bool isGpsEnabled = await Geolocator.isLocationServiceEnabled();
      return status.isGranted && isGpsEnabled;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si el dispositivo está usando una ubicación simulada en tiempo real.
  static Future<bool> isUsingFakeGps() async {
    // DESACTIVADO PARA IOS PARA EVITAR FALSOS POSITIVOS EN EL IPHONE REAL/SIMULADOR
    if (Platform.isIOS) return false; 

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 2),
        ),
      );
      return position.isMocked;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si la depuración USB está habilitada (Solo Android).
  static Future<bool> isUsbDebuggingEnabled() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool result = await _platform.invokeMethod('isUsbDebuggingEnabled');
      return result;
    } on PlatformException catch (e) {
      print("Error detectando USB Debugging: ${e.message}");
      return false;
    }
  }
}
