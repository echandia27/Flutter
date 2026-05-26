import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http; // Importamos el paquete que instalamos

// 🔑 PEGA AQUÍ TUS API KEYS REALES
const String apiKey1 = '4610de77593cced1fbab2bd27c29a19c';
const String apiKey2 = '914ce101597a48699fe20641262605';

void main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  print('🚀 Servidor del clima corriendo en: http://localhost:8080');

  await for (HttpRequest request in server) {
    // 1. Configuramos los headers (CORS para que Flutter pueda leer)
    request.response.headers.contentType = ContentType.json;
    request.response.headers.add('Access-Control-Allow-Origin', '*');

    // 2. Leemos los parámetros de la URL (ej: ?ciudad=Madrid&api=1)
    final uri = Uri.parse(request.uri.toString());
    final params = uri.queryParameters;
    
    String ciudad = params['ciudad'] ?? 'Bogota'; // Si no mandan ciudad, usa Bogota por defecto
    String apiElegida = params['api'] ?? '1';     // Si no mandan api, usa la 1 por defecto

    try {
      Map<String, dynamic> datosClima;

      // 3. Hacemos el Switch entre las dos APIs
      if (apiElegida == '1') {
        datosClima = await obtenerClimaOpenWeather(ciudad);
      } else {
        datosClima = await obtenerClimaWeatherApi(ciudad);
      }

      // 4. Enviamos la respuesta exitosa
      request.response.write(jsonEncode(datosClima));
    } catch (e) {
      // Si hay un error (ej: la ciudad no existe), enviamos un error
      print('Error: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.write(jsonEncode({'error': 'No se pudo obtener el clima'}));
    }

    await request.response.close();
  }
}

// 🌤️ FUNCIÓN API 1: OpenWeatherMap
Future<Map<String, dynamic>> obtenerClimaOpenWeather(String ciudad) async {
  // Construimos la URL con la ciudad y la key
  final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$ciudad&appid=$apiKey1&units=metric&lang=es');
  
  final respuesta = await http.get(url);
  final datos = jsonDecode(respuesta.body);

  // Retornamos un JSON estandarizado (igual para ambas APIs, así Flutter no se confunde)
  return {
    'ciudad': datos['name'],
    'temperatura': datos['main']['temp'].toDouble(),
    'descripcion': datos['weather'][0]['description'],
    'proveedor': 'OpenWeatherMap'
  };
}

// 🌦️ FUNCIÓN API 2: WeatherAPI
Future<Map<String, dynamic>> obtenerClimaWeatherApi(String ciudad) async {
  final url = Uri.parse('https://api.weatherapi.com/v1/current.json?key=$apiKey2&q=$ciudad&lang=es');
  
  final respuesta = await http.get(url);
  final datos = jsonDecode(respuesta.body);

  return {
    'ciudad': datos['location']['name'],
    'temperatura': datos['current']['temp_c'].toDouble(),
    'descripcion': datos['current']['condition']['text'],
    'proveedor': 'WeatherAPI'
  };
}