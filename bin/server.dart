import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'api/app_data.dart';
import 'api/provider.dart';
import 'data/mingo.dart';

final _router = Router()..get('/penalised-providers', _penalisedProviderHandler);

Response _penalisedProviderHandler(Request req) {
  return Response.ok(
    jsonEncode(MinGOData.penalisedProviders.map((e) => e.toJson()).toList()),
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': '*',
      'Access-Control-Expose-Headers': '*',
      'Access-Control-Allow-Methods': 'GET, PUT, POST, DELETE, HEAD, OPTIONS',
    },
  );
}

// ignore: unused_element
late Timer _cacheRefreshTimer;

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

void main(List<String> args) async {
  final ip = InternetAddress.anyIPv4;

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  final port = int.parse(Platform.environment['PORT'] ?? '1612');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');

  HttpOverrides.global = InvalidSslOverride();

  await AppDataApi.getAll();
  print('Data received');
  await ProvidersApi.setAllPricingInfo();
  print('Pricing info received');

  _cacheRefreshTimer = Timer.periodic(
    const Duration(hours: 24),
    (_) async {
      try {
        await AppDataApi.getAll();
        print('Data received');
        await ProvidersApi.setAllPricingInfo();
        print('Pricing info received');
      } catch (e) {
        print('$e');
        await AppDataApi.getAll();
        print('Data received');
        await ProvidersApi.setAllPricingInfo();
        print('Pricing info received');
      }
    },
  );
}
