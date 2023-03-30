import 'dart:async';

import 'package:clean_arquitecture_and_tdd/core/error/failures.dart';
import 'package:clean_arquitecture_and_tdd/core/usecases/usecase.dart';
import 'package:clean_arquitecture_and_tdd/core/util/input_converter.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'number_trivia_event.dart';

part 'number_trivia_state.dart';

const String serverFailureMessage = 'Server Failure';
const String cacheFailureMessage = 'Cache Failure';
const String invalidInputFailureMessage =
    'Invalid Input - The number must be a positive integer or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(Empty()) {
    on<GetTriviaForConcreteNumber>(_onGetTriviaForConcreteNumber);
    on<GetTriviaForRandomNumber>(_onGetTriviaForRandomNumber);
  }

  void _onGetTriviaForConcreteNumber(
      GetTriviaForConcreteNumber getTriviaForConcreteNumber,
      Emitter<NumberTriviaState> emit) {
    final inputEither = inputConverter
        .stringToUnsignedInteger(getTriviaForConcreteNumber.numberString);

    inputEither.fold(
        (failure) => emit(const Error(message: invalidInputFailureMessage)),
        (integer) async {
      emit(Loading());

      final failureOrTrivia =
          await getConcreteNumberTrivia(Params(number: integer));

      _eitherOrLoadedOrErrorState(emit, failureOrTrivia);
    });
  }

  void _onGetTriviaForRandomNumber(
      GetTriviaForRandomNumber getTriviaForRandomNumber,
      Emitter<NumberTriviaState> emit) async {
    emit(Loading());

    final failureOrTrivia = await getRandomNumberTrivia(NoParams());

    _eitherOrLoadedOrErrorState(emit, failureOrTrivia);
  }

  void _eitherOrLoadedOrErrorState(Emitter<NumberTriviaState> emit,
      Either<Failure, NumberTrivia> failureOrTrivia) {
    emit(failureOrTrivia.fold(
      (failure) => Error(message: _mapFailureToMessage(failure)),
      (trivia) => Loaded(trivia: trivia),
    ));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return serverFailureMessage;
      case CacheFailure:
        return cacheFailureMessage;
      default:
        return 'Unexpected error';
    }
  }
}
