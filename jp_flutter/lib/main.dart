import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MiAppClima());
}

class MiAppClima extends StatelessWidget {
  const MiAppClima({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App del Clima',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: const PaginaInicio(),
    );
  }
}

class PaginaInicio extends StatefulWidget {
  const PaginaInicio({super.key});

  @override
  State<PaginaInicio> createState() => _PaginaInicioState();
}

class _PaginaInicioState extends State<PaginaInicio> {
  // Variables de estado (lo que cambia en la UI)
  String _ciudadSeleccionada = 'Buenos Aires'; // Ciudad por defecto
  String _apiSeleccionada = '2'; // API por defecto (la 2 sabemos que funciona ya)
  
  // Datos del clima que vienen del backend
  String _temperatura = '--';
  String _descripcion = 'Presiona el botón';
  String _proveedor = '';

  // Lista de ciudades para el menú desplegable
  final List<String> _ciudades = ['Buenos Aires', 'Madrid', 'Bogota', 'Ciudad de Mexico', 'Lima'];

  // 🌐 FUNCIÓN PARA LLAMAR AL BACKEND
  Future<void> _obtenerClima() async {
    try {
      // Armamos la URL con los parámetros (igual que hiciste en el navegador)
      final url = Uri.parse('http://localhost:8080/?ciudad=$_ciudadSeleccionada&api=$_apiSeleccionada');
      
      // Hacemos la petición GET
      final respuesta = await http.get(url);

      // Si todo salió bien (código 200)
      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);
        
        // Actualizamos la UI con setState
        setState(() {
          _temperatura = datos['temperatura'].toString();
          _descripcion = datos['descripcion'];
          _proveedor = datos['proveedor'];
        });
      } else {
        setState(() {
          _descripcion = 'Error al obtener el clima';
        });
      }
    } catch (e) {
      setState(() {
        _descripcion = 'Error de conexión con el servidor';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌤️ Mi App del Clima'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            // 1. MENÚ DESPLEGABLE DE CIUDADES
            DropdownButton<String>(
              value: _ciudadSeleccionada,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              items: _ciudades.map((String ciudad) {
                return DropdownMenuItem(
                  value: ciudad,
                  child: Text(ciudad, style: const TextStyle(fontSize: 18)),
                );
              }).toList(),
              onChanged: (String? nuevaCiudad) {
                setState(() {
                  _ciudadSeleccionada = nuevaCiudad!;
                });
              },
            ),
            const SizedBox(height: 20),

            // 2. SWITCH PARA CAMBIAR DE API
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('API 1', style: TextStyle(fontWeight: _apiSeleccionada == '1' ? FontWeight.bold : FontWeight.normal)),
                Switch(
                  value: _apiSeleccionada == '2',
                  onChanged: (bool valor) {
                    setState(() {
                      _apiSeleccionada = valor ? '2' : '1';
                    });
                  },
                ),
                Text('API 2', style: TextStyle(fontWeight: _apiSeleccionada == '2' ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
            const SizedBox(height: 40),

            // 3. MOSTRAR DATOS DEL CLIMA
            Text(
              '$_temperatura °C',
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),
            Text(
              _descripcion,
              style: const TextStyle(fontSize: 24, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              'Fuente: $_proveedor',
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 40),

            // 4. BOTÓN PARA BUSCAR EL CLIMA
            ElevatedButton.icon(
              onPressed: _obtenerClima,
              icon: const Icon(Icons.search),
              label: const Text('Buscar Clima', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)
              ),
            ),

          ],
        ),
      ),
    );
  }
}