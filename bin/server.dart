import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_letsencrypt/shelf_letsencrypt.dart';

void main(List<String> args) async {
  final domain = 'min-go.hr';
  final domainEmail = 'info@min-go.hr';
  final certificatesDirectory = '/etc/ssl/certs';

  final certificatesHandler = CertificatesHandlerIO(Directory(certificatesDirectory));

  final letsEncrypt = LetsEncrypt(certificatesHandler, production: false);

  final pipeline = const Pipeline().addMiddleware(logRequests());
  final handler = pipeline.addHandler(_processRequest);

  final servers = await letsEncrypt.startSecureServer(
    handler,
    domain,
    domainEmail,
    port: 1312,
    securePort: 1612,
    checkCertificate: false,
  );

  final server = servers[0]; // HTTP Server.
  final serverSecure = servers[1]; // HTTPS Server.

  server.autoCompress = true;
  serverSecure.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
  print('Serving at https://${serverSecure.address.host}:${serverSecure.port}');
}

Response _processRequest(Request request) {
  return Response.ok('Requested: ${request.requestedUri}');
}
