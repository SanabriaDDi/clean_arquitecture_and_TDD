part of 'number_trivia_bloc.dart';

abstract class NumberTriviaEvent extends Equatable {
  const NumberTriviaEvent();
}

class GetTriviaForConcretNumber extends NumberTriviaEvent {
  final String numberString;

  const GetTriviaForConcretNumber(this.numberString);

  @override
  List<Object?> get props => [numberString];
}

class GetTriviaForRandomNumber extends NumberTriviaEvent {
  const GetTriviaForRandomNumber();

  @override
  List<Object?> get props => [];
}
