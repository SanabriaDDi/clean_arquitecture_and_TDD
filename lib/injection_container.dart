import 'package:clean_arquitecture_and_tdd/core/network/network_info.dart';
import 'package:clean_arquitecture_and_tdd/core/usecases/usecase.dart';
import 'package:clean_arquitecture_and_tdd/core/util/input_converter.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_arquitecture_and_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

Future<List<RepositoryProvider>> buildProviders() async {
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  return [
    //External
    RepositoryProvider<SharedPreferences>(
      create: (_) => sharedPreferences,
    ),
    RepositoryProvider<http.Client>(
      create: (_) => http.Client(),
    ),
    RepositoryProvider<InternetConnectionChecker>(
      create: (_) => InternetConnectionChecker.instance,
    ),

    //Core
    RepositoryProvider<InputConverter>(
      create: (_) => InputConverter(),
    ),
    RepositoryProvider<NetworkInfo>(
      create: (context) => NetworkInfoImpl(context.read()),
    ),

    //Data sources
    RepositoryProvider<NumberTriviaRemoteDataSource>(
      create: (context) => NumberTriviaRemoteDataSourceImpl(
        client: context.read(),
      ),
    ),
    RepositoryProvider<NumberTriviaLocalDataSource>(
      create: (context) => NumberTriviaLocalDataSourceImpl(
        sharedPreferences: context.read(),
      ),
    ),

    //Repository
    RepositoryProvider<NumberTriviaRepository>(
      create: (context) => NumberTriviaRepositoryImpl(
        remoteDataSource: context.read(),
        localDataSource: context.read(),
        networkInfo: context.read(),
      ),
    ),

    //Use cases
    RepositoryProvider<GetConcreteNumberTrivia>(
      create: (context) => GetConcreteNumberTrivia(
        context.read(),
      ),
    ),
    RepositoryProvider<GetRandomNumberTrivia>(
      create: (context) => GetRandomNumberTrivia(
        context.read(),
      ),
    ),
  ];
}
