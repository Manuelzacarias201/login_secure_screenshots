import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'security_service.dart';

/// Manejador de mensajes en segundo plano (debe ser una función global o estática).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Asegurarse de que Firebase esté inicializado si se llama en segundo plano
  await Firebase.initializeApp();
  
  if (message.data['action'] == 'wipe_data') {
    await SecurityService.wipeSensitiveData();
  }
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Solicitar permisos (especialmente para iOS)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      
      // Obtener el token FCM para pruebas
      String? token = await _messaging.getToken();
      print("FCM Token: $token");

      // Configurar el manejador de segundo plano
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Manejador en primer plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print('Got a message whilst in the foreground!');
        if (message.data['action'] == 'wipe_data') {
          await SecurityService.wipeSensitiveData();
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }
}
