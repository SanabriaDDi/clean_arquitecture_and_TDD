import 'dart:convert';

import 'package:clean_arquitecture_and_tdd/core/error/exceptions.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:http/http.dart' as http;

abstract class NumberTriviaRemoteDataSource {
  /// Calls the http://numbersapi.com/{number} endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);

  /// Calls the http://numbersapi.com/random endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final http.Client client;

  NumberTriviaRemoteDataSourceImpl({required this.client});

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) =>
      _getTriviaFromUrl('$number');

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() =>
      _getTriviaFromUrl('random');

  Future<NumberTriviaModel> _getTriviaFromUrl(String unencodedPath) async {
    final uri = Uri.http('numbersapi.com', unencodedPath);
    final response = await client.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw ServerException();
    }

    return NumberTriviaModel.fromJson(json.decode(response.body));
  }
}
