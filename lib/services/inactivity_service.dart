import 'dart:async';
import 'package:flutter/material.dart';

class InactivityService {
  static Timer? _timer;
  static const int _timeoutSeconds = 15; // Tiempo de inactividad para pruebas
  static VoidCallback? _onTimeout;

  /// Inicializa el servicio con el callback a ejecutar al expirar el tiempo
  static void initialize({required VoidCallback onTimeout}) {
    _onTimeout = onTimeout;
    resetTimer();
  }

  /// Reinicia el temporizador de inactividad
  static void resetTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: _timeoutSeconds), () {
      if (_onTimeout != null) {
        _onTimeout!();
      }
    });
  }

  /// Detiene el temporizador (por ejemplo, al cerrar sesión manualmente)
  static void stopTimer() {
    _timer?.cancel();
  }
}
