import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/warning_screen.dart';
import 'services/security_service.dart';
import 'services/notification_service.dart';
import 'services/inactivity_service.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase (Requiere google-services.json configurado)
  try {
    await Firebase.initializeApp();
    await NotificationService.initialize();
  } catch (e) {
    print("Error inicializando Firebase: $e");
    print("Asegúrate de haber agregado los archivos de configuración de Firebase.");
  }

  // Inicializar datos sensibles
  await SecurityService.initSensitiveData();

  runApp(const SecurityApp());
}

class SecurityApp extends StatefulWidget {
  const SecurityApp({super.key});

  @override
  State<SecurityApp> createState() => _SecurityAppState();
}

class _SecurityAppState extends State<SecurityApp> {
  bool _isBlocked = false;
  bool _isLoading = true;
  String _errorMsg = "";
  Timer? _securityTimer;
  bool _isDialogShowing = false;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Esperar a que el primer frame se dibuje para realizar chequeos de UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialSecurityCheck();
      _startRealTimeMonitoring();
    });

    // INICIALIZAR CONTROL DE INACTIVIDAD
    InactivityService.initialize(
      onTimeout: () {
        // Redirigir al Login y limpiar el historial
        _navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
        
        // Mostrar aviso al usuario
        final context = _navigatorKey.currentContext;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sesión expirada por inactividad (15s)"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _securityTimer?.cancel();
    InactivityService.stopTimer();
    super.dispose();
  }

  /// Primera validación al abrir la app
  Future<void> _initialSecurityCheck() async {
    await _performSecurityCheck();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// Inicia un temporizador que vigila el estado de seguridad sin parar
  void _startRealTimeMonitoring() {
    _securityTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _performSecurityCheck();
    });
  }

  /// LÓGICA DE VALIDACIÓN EN TIEMPO REAL
  Future<void> _performSecurityCheck() async {
    // Implementación Opción B: Detección Nativa de Depuración USB
    bool isUsbDebug = await SecurityService.isUsbDebuggingEnabled();

    if (isUsbDebug) {
      _showSecurityDialog(
        "Depuración USB Detectada",
        "Por motivos de seguridad, la aplicación no puede ejecutarse con la Depuración USB activada. Por favor, desactívala en los ajustes del sistema para continuar."
      );
      return;
    }

    // Otras validaciones (puedes mantenerlas o quitarlas según necesites)
    bool isFake = await SecurityService.isUsingFakeGps();
    if (isFake) {
      if (mounted) {
        setState(() {
          _isBlocked = true;
          _errorMsg = "Se ha detectado una ubicación simulada.";
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isBlocked = false;
          _errorMsg = "";
        });
      }
    }
  }

  void _showSecurityDialog(String title, String message) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    final context = _navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false, // Persistente
      builder: (context) => PopScope(
        canPop: false, // No se puede cerrar con el botón atrás
        child: AlertDialog(
          title: Text(title, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                // Cerrar la aplicación de forma limpia
                SystemNavigator.pop();
              },
              child: const Text("SALIR"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => InactivityService.resetTimer(),
      onPointerMove: (_) => InactivityService.resetTimer(),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Práctica Seguridad Móvil',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true, 
          colorSchemeSeed: Colors.blue,
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
        home: _isLoading
            ? const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              )
            : _isBlocked 
                ? WarningScreen(
                    message: _errorMsg,
                    onRetry: _performSecurityCheck, // El botón sigue ahí por usabilidad manual
                  ) 
                : const LoginScreen(),
      ),
    );
  }
}
