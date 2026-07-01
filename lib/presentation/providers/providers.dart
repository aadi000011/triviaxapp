import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/trivia_repository.dart';
import '../../data/services/trivia_api_service.dart';

final triviaApiServiceProvider = Provider<TriviaApiService>((ref) {
  return TriviaApiService();
});

final triviaRepositoryProvider = Provider<TriviaRepository>((ref) {
  return TriviaRepository(apiService: ref.read(triviaApiServiceProvider));
});
