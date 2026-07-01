import 'package:get/get.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/quiz_screen.dart';
import '../presentation/screens/result_screen.dart';
import '../presentation/screens/admin_screen.dart';
import '../presentation/screens/custom_quiz_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String quiz = '/quiz';
  static const String result = '/result';
  static const String admin = '/admin';
  static const String customQuiz = '/custom-quiz';

  static List<GetPage> routes = [
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: quiz,
      page: () => const QuizScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: result,
      page: () => const ResultScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: admin,
      page: () =>  AdminScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: customQuiz,
      page: () => const CustomQuizScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
