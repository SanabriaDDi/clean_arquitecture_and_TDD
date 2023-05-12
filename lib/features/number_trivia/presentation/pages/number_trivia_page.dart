import 'package:clean_arquitecture_and_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Trivia'),
      ),
      body: BlocProvider(
        create: (context) => NumberTriviaBloc(
          getConcreteNumberTrivia: context.read(),
          getRandomNumberTrivia: context.read(),
          inputConverter: context.read(),
        ),
        child: const SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: BuildBody(),
            ),
          ),
        ),
      ),
    );
  }
}

class BuildBody extends StatelessWidget {
  const BuildBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 10),
      BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
        builder: (context, state) {
          if (state is Empty) {
            return const MessageDisplay(
              message: 'Start searching!',
            );
          }
          if (state is Loading) {
            return const LoadingWidget();
          }
          if (state is Loaded) {
            return TriviaDisplay(numberTrivia: state.trivia);
          }
          if (state is Error) {
            return MessageDisplay(message: state.message);
          }

          return SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            child: const Placeholder(),
          );
        },
      ),
      const SizedBox(height: 20),
      //Bottom half
      const TriviaControls(),
    ]);
  }
}
