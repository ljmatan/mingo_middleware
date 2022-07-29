import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../data/mingo.dart';

import 'package:http/http.dart' as http;

part 'handlers/penalised_providers.dart';

abstract class MinGORouter {
  static final instance = Router()..get('/penalised-providers', _penalisedProviderHandler);
}
