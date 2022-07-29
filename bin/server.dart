import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

import 'api/app_data.dart';
import 'api/client.dart';
import 'api/provider.dart';
import 'router/router.dart';

SecurityContext getSecurityContext() {
  // Bind with a secure HTTPS connection
  final chain = Platform.script.resolve('../mingo_hr_0.crt').toFilePath();
  final key = Platform.script.resolve('../mingo_hr_0.key').toFilePath();

  return SecurityContext()
    ..useCertificateChain(chain)
    ..usePrivateKey(key, password: '8g{X7CPWg?1?');
}

// ignore: unused_element
late Timer _cacheRefreshTimer;

void main(List<String> args) async {
  final ip = InternetAddress.anyIPv4;

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(MinGORouter.instance);

  final port = int.parse(Platform.environment['PORT'] ?? '1612');
  final server = await serve(handler, ip, port, securityContext: getSecurityContext());
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
