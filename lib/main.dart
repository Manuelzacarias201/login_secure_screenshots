import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/warning_screen.dart';
import 'services/security_service.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

  @override
  void initState() {
    super.initState();
    // Primera validación inmediata
    _initialSecurityCheck();
    // Iniciamos el MONITOREO CONSTANTE (Cada 2 segundos)
    _startRealTimeMonitoring();
  }

  @override
  void dispose() {
    _securityTimer?.cancel();
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
    try {
      // 1. Verificar permisos (Sin permisos no podemos vigilar el Fake GPS)
      bool hasPerms = await SecurityService.hasLocationPermissions();
      if (!hasPerms) {
        if (mounted && !_isBlocked) {
          setState(() {
            _isBlocked = true;
            _errorMsg = "Se requieren permisos de ubicación para garantizar la seguridad.";
          });
        }
        return;
      }

      // 2. Comprobar Fake GPS (API Nativa)
      bool isFake = await SecurityService.isUsingFakeGps();

      if (mounted) {
        // CAMBIO DINÁMICO DE PANTALLA:
        // Si el estado cambia (se activa o desactiva el Fake GPS), actualizamos la UI inmediatamente.
        if (isFake != _isBlocked || (isFake && _errorMsg.isEmpty)) {
          setState(() {
            _isBlocked = isFake;
            _errorMsg = isFake 
                ? "Se ha detectado el uso de una 'Fake GPS API'. Desactívala para continuar." 
                : "";
          });
        }
      }
    } catch (e) {
      // Ante error, mantenemos el estado anterior por estabilidad
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Práctica Seguridad Móvil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true, 
        colorSchemeSeed: Colors.blue,
      ),
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
    );
  }
}
