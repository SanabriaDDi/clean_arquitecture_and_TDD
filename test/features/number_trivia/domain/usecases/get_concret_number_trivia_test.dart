import 'package:clean_arquitecture_and_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  late GetConcreteNumberTrivia usecase;
  late MockNumberTriviaRepository mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetConcreteNumberTrivia(mockNumberTriviaRepository);
  });

  const tNumber = 1;
  const tNumberTrivia = NumberTrivia(number: tNumber, text: 'test');

  test('should get trivia for the number from the repository', () async {
    // arrange
    when(() => mockNumberTriviaRepository.getConcreteNumberTrivia(any()))
        .thenAnswer((_) async => const Right(tNumberTrivia));
    // act
    final result = await usecase(number: tNumber);
    // assert
    expect(result, const Right(tNumberTrivia));
    verify(() => mockNumberTriviaRepository.getConcreteNumberTrivia(tNumber))
        .called(1);
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}
