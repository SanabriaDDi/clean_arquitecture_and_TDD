import 'package:bloc_test/bloc_test.dart';
import 'package:clean_arquitecture_and_tdd/core/error/failures.dart';
import 'package:clean_arquitecture_and_tdd/core/usecases/usecase.dart';
import 'package:clean_arquitecture_and_tdd/core/util/input_converter.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

class MyParamsFake extends Fake implements Params {}

class MyNoParamsFake extends Fake implements NoParams {}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    registerFallbackValue(MyParamsFake());
    registerFallbackValue(MyNoParamsFake());
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initialState should be Empty', () async {
    // arrange
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    const tNumberString = '1';
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    void setUpMockInputConverterSuccess() =>
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(const Right(tNumberParsed));

    void setUpMockGetConcreteNumberTriviaSuccess() =>
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => const Right(tNumberTrivia));

    /*blocTest(
      'should call the InputConverter to validate and convert the string to an unsigned integer (using bloc_test library)',
      build: () {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();
        return bloc;
      },
      act: (bloc) => bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      verify: (_) {
        verify(() => mockInputConverter.stringToUnsignedInteger(tNumberString))
            .called(1);
      },
    );*/

    test(
        'should call the InputConverter to validate and convert the string to an unsigned integer',
        () async {
      // arrange
      setUpMockInputConverterSuccess();
      setUpMockGetConcreteNumberTriviaSuccess();
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(
          () => mockInputConverter.stringToUnsignedInteger(any()));
      // assert
      verify(() => mockInputConverter.stringToUnsignedInteger(tNumberString))
          .called(1);
    });

    /*blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Error] when input is invalid',
      build: () {
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(Left(InvalidInputFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [
        //Empty(),
        const Error(message: invalidInputFailureMessage),
      ],
    );*/

    test('should emit [Error] when input is invalid', () async {
      // arrange
      when(() => mockInputConverter.stringToUnsignedInteger(any()))
          .thenReturn(Left(InvalidInputFailure()));
      // assert later
      final expected = [
        const Error(message: invalidInputFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test('should get data from the concrete use case', () async {
      // arrange
      setUpMockInputConverterSuccess();
      setUpMockGetConcreteNumberTriviaSuccess();
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(() => mockGetConcreteNumberTrivia(any()));
      // assert
      verify(() =>
          mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
    });

    test('should emit [Loading, Loaded] when data is gotten successfuly',
        () async {
      // arrange
      setUpMockInputConverterSuccess();
      setUpMockGetConcreteNumberTriviaSuccess();
      // assert later

      final expected = [
        Loading(),
        const Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test('should emit [Loading, Error] when getting data fails', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => Left(ServerFailure()));
      // assert later

      final expected = [
        Loading(),
        const Error(message: serverFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test(
        'should emit [Loading, Error] with a proper message for the error when getting data fails',
        () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => Left(CacheFailure()));
      // assert later

      final expected = [
        Loading(),
        const Error(message: cacheFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });
  });

  group('GetTriviaForRandomNumber', () {
    const tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    void setUpMockGetRandomNumberTriviaSuccess() =>
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => const Right(tNumberTrivia));

    test('should get data from the random use case', () async {
      // arrange
      setUpMockGetRandomNumberTriviaSuccess();
      // act
      bloc.add(const GetTriviaForRandomNumber());
      await untilCalled(() => mockGetRandomNumberTrivia(any()));
      // assert
      verify(() => mockGetRandomNumberTrivia(NoParams()));
    });

    test('should emit [Loading, Loaded] when data is gotten successfuly',
        () async {
      // arrange
      setUpMockGetRandomNumberTriviaSuccess();
      // assert later

      final expected = [
        Loading(),
        const Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(const GetTriviaForRandomNumber());
    });

    test('should emit [Loading, Error] when getting data fails', () async {
      // arrange
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((_) async => Left(ServerFailure()));
      // assert later

      final expected = [
        Loading(),
        const Error(message: serverFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(const GetTriviaForRandomNumber());
    });

    test(
        'should emit [Loading, Error] with a proper message for the error when getting data fails',
        () async {
      // arrange
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((_) async => Left(CacheFailure()));
      // assert later

      final expected = [
        Loading(),
        const Error(message: cacheFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(const GetTriviaForRandomNumber());
    });
  });
}
