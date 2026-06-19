import 'package:flutter/material.dart';
import '../services/security_service.dart';
import '../services/inactivity_service.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, String?> _sensitiveData = {};
  bool _isLoading = true;
  StreamSubscription? _updateSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Escuchar actualizaciones (notificaciones o botones)
    _updateSubscription = SecurityService.onDataUpdate.listen((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await SecurityService.getAllSensitiveData();
    if (mounted) {
      setState(() {
        _sensitiveData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Control Seguro"),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Estado de Datos Sensibles en Almacenamiento Seguro:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: _sensitiveData.entries.map((entry) {
                        final bool exists = entry.value != null;
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 15),
                          color: exists ? Colors.green[50] : Colors.red[50],
                          child: ListTile(
                            leading: Icon(
                              exists ? Icons.lock : Icons.lock_open,
                              color: exists ? Colors.green : Colors.red,
                            ),
                            title: Text(entry.key),
                            subtitle: Text(
                              exists ? "DATO PROTEGIDO: ${entry.value}" : "DATOS ELIMINADOS",
                              style: TextStyle(
                                color: exists ? Colors.black87 : Colors.red,
                                fontWeight: exists ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.info_outline, color: Colors.blue),
                    title: Text("Instrucción de Prueba"),
                    subtitle: Text(
                        "Envía una notificación de Firebase con 'action: wipe_data' para ver estos campos ponerse en rojo automáticamente."),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        setState(() => _isLoading = true);
                        await SecurityService.forceUpdateData();
                      },
                      icon: const Icon(Icons.download),
                      label: const Text("CARGAR DATOS DE NUEVO"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        InactivityService.stopTimer();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text("CERRAR SESIÓN"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
