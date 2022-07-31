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
  final chain = Platform.script.resolve('../fullchain.pem').toFilePath();
  final key = Platform.script.resolve('../privkey.pem').toFilePath();

  return SecurityContext()
    ..useCertificateChain(chain)
    ..usePrivateKey(key);
}

void main(List<String> args) async {
  HttpOverrides.global = InvalidSslOverride();

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(MinGORouter.instance);

  final server = await serve(
    handler,
    InternetAddress.anyIPv4,
    1612,
    securityContext: getSecurityContext(),
  );
  print('Server listening on port ${server.port}');

  print('Getting data');
  await AppDataApi.getAll();
  print('Data received');
  await ProvidersApi.setAllPricingInfo();
  print('Pricing info received');

  Timer.periodic(
    const Duration(hours: 8),
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
