part of '../router.dart';

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
