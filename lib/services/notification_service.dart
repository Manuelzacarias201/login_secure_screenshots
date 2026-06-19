import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'security_service.dart';

/// Manejador de mensajes en segundo plano (debe ser una función global o estática).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Asegurarse de que Firebase esté inicializado si se llama en segundo plano
  await Firebase.initializeApp();
  
  print("Background message received: ${message.messageId}");
  
  bool shouldWipe = message.data['action'] == 'wipe_data' || 
                    (message.notification?.body?.contains('wipe_data') ?? false);

  if (shouldWipe) {
    await SecurityService.wipeSensitiveData();
  } else if (message.data['action'] == 'reload_data') {
    await SecurityService.forceUpdateData();
  }
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static String? fcmToken;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  static Future<void> initialize() async {
    // Inicializar notificaciones locales para mostrar el banner en primer plano
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Manejar click en la notificacion local si es necesario
      },
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(_channel);

    // Configurar el manejador de segundo plano ANTES de otras inicializaciones
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Solicitar permisos (especialmente para iOS y Android 13+)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      
      // Obtener el token FCM para pruebas
      fcmToken = await _messaging.getToken();
      print("FCM Token: $fcmToken");

      // Manejador en primer plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print('Got a message whilst in the foreground!');
        
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        // Si hay una notificacion y es en primer plano, la mostramos manualmente
        if (notification != null) {
          _localNotifications.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                icon: 'ic_notification',
              ),
            ),
          );
        }

        bool shouldWipe = message.data['action'] == 'wipe_data' || 
                          (message.notification?.body?.contains('wipe_data') ?? false);

        if (shouldWipe) {
          await SecurityService.wipeSensitiveData();
        } else if (message.data['action'] == 'reload_data') {
          await SecurityService.forceUpdateData();
        }
      });

      // Manejador cuando se abre la app desde una notificación
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        print('A new onMessageOpenedApp event was published!');
        bool shouldWipe = message.data['action'] == 'wipe_data' || 
                          (message.notification?.body?.contains('wipe_data') ?? false);
        if (shouldWipe) {
          await SecurityService.wipeSensitiveData();
        } else if (message.data['action'] == 'reload_data') {
          await SecurityService.forceUpdateData();
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }
}
