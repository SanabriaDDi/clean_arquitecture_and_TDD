import 'dart:convert';

import 'package:clean_arquitecture_and_tdd/core/error/exceptions.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

import '../../../../fixtures/fixtures_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    registerFallbackValue(FakeUri());
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404() {
    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel =
    NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test('''should perform a GET request in a URL with number 
        beign the endpoint and with application/json header''', () async {
      // arrange
      setUpMockHttpClientSuccess200();
      // act
      dataSource.getConcreteNumberTrivia(tNumber);
      // assert
      verify(
            () =>
            mockHttpClient.get(
              Uri.http('numbersapi.com', '$tNumber'),
              headers: {'Content-Type': 'application/json'},
            ),
      );
    });

    test('should return Number trivia when the response code is 200', () async {
      // arrange
      setUpMockHttpClientSuccess200();
      // act
      final result = await dataSource.getConcreteNumberTrivia(tNumber);
      // assert
      expect(result, equals(tNumberTriviaModel));
    });

    test('''should throw a ServerException when the response code 
     is 404 or other''', () async {
      // arrange
      setUpMockHttpClientFailure404();
      // act
      final call = dataSource.getConcreteNumberTrivia;
      // assert
      expect(() => call(tNumber), throwsA(isA<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
    NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test('''should perform a GET request in a URL with number 
        beign the endpoint and with application/json header''', () async {
      // arrange
      setUpMockHttpClientSuccess200();
      // act
      dataSource.getRandomNumberTrivia();
      // assert
      verify(
            () =>
            mockHttpClient.get(
              Uri.http('numbersapi.com', 'random'),
              headers: {'Content-Type': 'application/json'},
            ),
      );
    });

    test('should return Number trivia when the response code is 200', () async {
      // arrange
      setUpMockHttpClientSuccess200();
      // act
      final result = await dataSource.getRandomNumberTrivia();
      // assert
      expect(result, equals(tNumberTriviaModel));
    });

    test('''should throw a ServerException when the response code 
     is 404 or other''', () async {
      // arrange
      setUpMockHttpClientFailure404();
      // act
      final call = dataSource.getRandomNumberTrivia;
      // assert
      expect(() => call(), throwsA(isA<ServerException>()));
    });
  });
}
