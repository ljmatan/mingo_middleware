part of '../router.dart';

Future<Response> _stationsByTypeHandler(Request req) async {
  return Response.ok(
    jsonEncode(MinGOData.stationsByType),
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': '*',
      'Access-Control-Expose-Headers': '*',
      'Access-Control-Allow-Methods': 'GET, PUT, POST, DELETE, HEAD, OPTIONS',
    },
  );
}
