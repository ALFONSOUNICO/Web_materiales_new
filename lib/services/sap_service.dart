import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/material.dart';

class SapService {
  static const String baseUrl =
      'https://gsesrwdcc.santaelena.com.pe:44300/zmat_vbap_consu/material';

  Future<MaterialResponse> consultarMateriales({
    required String usuario,
    required String password,
    required String materialDesde,
    required String materialHasta,
    required String fechaDesde,
    required String fechaHasta,
    int pageSize = 20,
    int offset = 0,
  }) async {
    // Convertir las fechas del formato visual de Flutter:
    // YYYY-MM-DD
    // al formato requerido por SAP:
    // YYYYMMDD
    final fechaDesdeSap = fechaDesde.replaceAll('-', '');
    final fechaHastaSap = fechaHasta.replaceAll('-', '');

    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'sap-client': '200',
        'MATNR_DESDE': materialDesde,
        'MATNR_HASTA': materialHasta,
        'PAGE_SIZE': pageSize.toString(),
        'OFFSET': offset.toString(),
        'FECHA_DESDE': fechaDesdeSap,
        'FECHA_HASTA': fechaHastaSap,
      },
    );

    // Autenticación Basic de SAP
    final credentials = base64Encode(
      utf8.encode('$usuario:$password'),
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Basic $credentials',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData =
          jsonDecode(response.body) as Map<String, dynamic>;

      return MaterialResponse.fromJson(jsonData);
    }

    if (response.statusCode == 401) {
      throw Exception(
        'Usuario o contraseña incorrectos para SAP.',
      );
    }

    throw Exception(
      'Error al consultar SAP. Código HTTP: ${response.statusCode}',
    );
  }
}