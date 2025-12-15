import 'package:flutter/material.dart';
import 'package:landmarkcoop_latest/pages/login_screen.dart';
import 'package:landmarkcoop_latest/pages/sing_up_screen.dart';
import 'package:landmarkcoop_latest/pages/sing_up_screen_2.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  PageController controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        controller: controller,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return LoginScreen(
                controller: controller,
              );
            case 1:
              return SingUpScreen(
                controller: controller,
              );
            // case 2:
            //   return SingUpScreen2(
            //     controller: controller,
            //   );
          }
        },
      ),
    );
  }
}
