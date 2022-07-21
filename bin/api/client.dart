import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class InvalidSslOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (
        X509Certificate cert,
        String host,
        int port,
      ) {
        return true;
      };
  }
}

abstract class MinGOHttpClient {
  static Map<String, String> get _headers => {
        'Referer': 'https://mzoe-gor.hr',
      };

  static Future<dynamic> get(
    String url, {
    Map<String, String>? headers,
    bool decoded = true,
  }) async {
    final response = await http
        .get(
          Uri.parse(url),
          headers: headers ?? _headers,
        )
        .timeout(
          const Duration(seconds: 8),
          onTimeout: () => throw 'Nešto je pošlo po zlu',
        );

    if (response.statusCode != 200) throw 'Nešto je pošlo po zlu';

    return decoded ? jsonDecode(response.body) : response;
  }

  static Future<dynamic> post(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    bool encoded = true,
    bool decoded = true,
  }) async {
    http.Response response = await http
        .post(
          Uri.parse(url),
          body: jsonEncode(body),
          headers: headers ?? _headers,
        )
        .timeout(
          const Duration(seconds: 8),
          onTimeout: () => throw 'Nešto je pošlo po zlu',
        );

    Future<void> redirection() async {
      final locationHeader = response.headers['location'];
      if (locationHeader != null) {
        final redirectLocation = response.headers['location'] as String;
        response = await http
            .post(
              Uri.parse(redirectLocation),
              body: jsonEncode(body),
              headers: headers ?? _headers,
            )
            .timeout(
              const Duration(seconds: 8),
              onTimeout: () => throw 'Nešto je pošlo po zlu',
            );
      }
    }

    if (response.statusCode == 308) await redirection();

    if (response.statusCode == 301) await redirection();

    if (response.statusCode != 200) throw 'Nešto je pošlo po zlu';

    return decoded ? jsonDecode(response.body) : response;
  }
}
