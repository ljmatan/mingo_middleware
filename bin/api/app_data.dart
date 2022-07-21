import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../data/mingo.dart';
import '../models/app_data.dart';

abstract class AppDataApi {
  static Future<AppDataModel> getAll() async {
    final http.Response response = await http.get(
      Uri.parse('https://mzoe-gor.hr/data.gz'),
      headers: {
        'Referer': 'https://mzoe-gor.hr',
      },
    );
    print('Data response received');
    final extracted = GZipCodec().decode(response.bodyBytes);
    print('Data response extracted: ${extracted.length}');
    final utf8Decoded = utf8.decode(extracted, allowMalformed: true);
    print('Data response utf8 decoded');
    final jsonDecoded = jsonDecode(utf8Decoded);
    print('Data response JSON decoded');
    final data = AppDataModel.fromJson(jsonDecoded);
    print('Data response serialized');
    MinGOData.input = data;

    return MinGOData.instance;
  }
}
