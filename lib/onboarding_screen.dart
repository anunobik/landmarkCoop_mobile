import 'package:flutter/material.dart';
import 'package:landmarkcoop_latest/main_view.dart';
import 'package:landmarkcoop_latest/pages/sing_up_screen.dart';
import 'package:landmarkcoop_latest/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_contents.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _controller;
  String institution = 'Landmark Coop';
  String subdomain = 'https://core.landmarkcooperative.org';
  PageController controller = PageController(initialPage: 0);
  PageController controller2 = PageController(initialPage: 1);

  @override
  void initState() {
    _controller = PageController();
    setInstitution(institution, subdomain);
    super.initState();
  }

  setInstitution(String institution, String subdomain) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('institution', institution);
    prefs.setString('subdomain', subdomain);
  }

  int _currentPage = 0;
  List colors = const [
    Color(0xffDAD3C8),
    Color(0xffFFE5DE),
    Color(0xffDCF6E6),
  ];
  List imageUri = const [
    "assets/images/blackwoman-phone.jpg",
    "assets/images/twoguys-phone.png",
    "assets/images/woman-selling.jpg",
  ];

  AnimatedContainer _buildDots({
    int? index,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
        color: Colors.white,
      ),
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      curve: Curves.easeIn,
      width: _currentPage == index ? 20 : 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double width = SizeConfig.screenW!;
    double height = SizeConfig.screenH!;

    return Scaffold(
      backgroundColor: colors[_currentPage],
      body: Container(
        padding: const EdgeInsets.only(top: 20),
        height: height,
        width: width,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(imageUri[_currentPage]), fit: BoxFit.cover),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.5), // Adjust the opacity as needed
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                physics: const BouncingScrollPhysics(),
                controller: _controller,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: contents.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: height / 2,
                        ),
                        Text(
                          contents[i].title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.w900,
                            fontSize: (width <= 550) ? 30 : 35,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          contents[i].desc,
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.w600,
                            fontSize: (width <= 550) ? 12 : 20,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      contents.length,
                      (int index) => _buildDots(
                        index: index,
                      ),
                    ),
                  ),
                  _currentPage + 1 == contents.length
                      ? Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        SingUpScreen(controller: controller)));
                              },
                              child: const Text(
                                "Create new account",
                                style: TextStyle(
                                  fontFamily: "Mulish",
                                  color: Colors.black,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                fixedSize: Size((width * 0.7), 50.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                // padding: (width <= 550)
                                //     ? const EdgeInsets.symmetric(
                                //         horizontal: 80, vertical: 20)
                                //     : EdgeInsets.symmetric(
                                //         horizontal: width * 0.2, vertical: 25),
                                textStyle: TextStyle(
                                    fontSize: (width <= 550) ? 15 : 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => MainView()));
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  fontFamily: "Mulish",
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                fixedSize: Size((width * 0.7), 50.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                // padding: (width <= 550)
                                //     ? const EdgeInsets.symmetric(
                                //     horizontal: 80, vertical: 20)
                                //     : EdgeInsets.symmetric(
                                //     horizontal: width * 0.2, vertical: 25),
                                textStyle: TextStyle(
                                    fontSize: (width <= 550) ? 15 : 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.all(30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _controller.jumpToPage(2);
                                },
                                child: const Text(
                                  "SKIP",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: TextButton.styleFrom(
                                  elevation: 0,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: (width <= 550) ? 15 : 19,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _controller.nextPage(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeIn,
                                  );
                                },
                                child: const Text("NEXT"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  elevation: 0,
                                  padding: (width <= 550)
                                      ? const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 20)
                                      : const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 25),
                                  textStyle: TextStyle(
                                      fontSize: (width <= 550) ? 13 : 17),
                                ),
                              ),
                            ],
                          ),
                        )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
