import 'package:clean_arquitecture_and_tdd/features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'package:clean_arquitecture_and_tdd/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repositories = await buildProviders();
  runApp(MyApp(repositories));
}

class MyApp extends StatelessWidget {
  final List<RepositoryProvider> repositories;

  const MyApp(this.repositories, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: repositories,
      child: MaterialApp(
        title: 'Number trivia',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.green.shade800,
            secondary: Colors.green.shade600,
          ),
        ),
        home: const NumberTriviaPage(),
      ),
    );
  }
}
