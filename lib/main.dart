import 'dart:async';

// import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/main_view.dart';
import 'package:landmarkcoop_mobile_app/splash_screen.dart';
import 'package:landmarkcoop_mobile_app/utils/firebase_options.dart';
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  //for notificaiton initialization
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //for background messaging
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  //Local Notification implementation
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  //for firebase  plugin and messaging required

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  runApp(const RoyalMarshal());
}

class RoyalMarshal extends StatelessWidget {
  const RoyalMarshal({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // home: StartPage(),
        home: SplashScreen(),
      ),
    );
  }
}

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  // final CarouselController _carouselController = CarouselController();
  int _currentIndex = 0;
  bool isInstitutionDialogShown = false;

  // List<ClientResponseModel> clientList = <ClientResponseModel>[];
  List cardList = [
    const Item1(),
    const Item2(),
    const Item3(),
    const Item4(),
  ];
  String institution = 'Landmark Coop';
  String subdomain = 'https://core.landmarkcooperative.org';

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  setInstitution(String institution, String subdomain) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('institution', institution);
    prefs.setString('subdomain', subdomain);
  }

  startTimer() async {
    final prefs = await SharedPreferences.getInstance();
    String institution = prefs.getString('institution') ?? '';
    String subdomain = prefs.getString('subdomain') ?? '';
    print('Institution is $institution');
    print('Biometric token ${prefs.getString('biometricToken')!}');
    Timer(const Duration(seconds: 10), () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MainView()));
    });
  }

  @override
  void initState() {
    setInstitution(institution, subdomain);
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            Container(
              height: height * 0.1,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Text(
              'Landmark Coop',
              style: GoogleFonts.montserrat(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            // SizedBox(height: height / 300),
            // CarouselSlider(
            //   items: cardList
            //       .map(
            //         (data) => Builder(builder: (BuildContext context) {
            //           return SizedBox(
            //             height: (height * 0.5).roundToDouble(),
            //             child: Container(
            //               // margin: const EdgeInsets.symmetric(horizontal: 5),
            //               padding: const EdgeInsets.symmetric(horizontal: 10),
            //               height: (height * 0.122).roundToDouble(),
            //               child: data,
            //             ),
            //           );
            //         }),
            //       )
            //       .toList(),
            //   // carouselController: _carouselController,
            //   options: CarouselOptions(
            //       height: height * 0.5,
            //       autoPlay: true,
            //       enlargeCenterPage: true,
            //       autoPlayInterval: const Duration(seconds: 5),
            //       autoPlayAnimationDuration: const Duration(milliseconds: 800),
            //       autoPlayCurve: Curves.fastOutSlowIn,
            //       onPageChanged: (index, reason) {
            //         setState(() {
            //           _currentIndex = index;
            //         });
            //       }),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: map<Widget>(
                cardList,
                ((index, url) {
                  return Container(
                    height: 12.0,
                    width: 12.0,
                    margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Colors.blue
                          : Colors.black12,
                    ),
                  );
                }),
              ),
            ),
            // ElevatedButton(
            //     onPressed: () {},
            //     style: ElevatedButton.styleFrom(
            //         backgroundColor: Colors.white,
            //         fixedSize: Size((width * 0.7), 40.0), // Set width and height
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(10),
            //         )),
            //     child: Text(
            //       'Create an account',
            //       style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold),
            //     )),
            // SizedBox(height: 5),
            // ElevatedButton(
            //     onPressed: () {},
            //     style: ElevatedButton.styleFrom(
            //         backgroundColor: Colors.blue[800],
            //         fixedSize: Size((width * 0.7), 40.0), // Set width and height
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(10),
            //         )),
            //     child: Text(
            //       'Login',
            //       style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
            //     )),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MainView()));
              },
              child: Text(
                textAlign: TextAlign.center,
                'Tap to\n\nLogin or Sign Up',
                style: GoogleFonts.montserrat(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Item1 extends StatelessWidget {
  const Item1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 0.2 * height,
            width: 0.2 * width,
            // child: Image.asset(
            //   'assets/pics/core_bank.jpg',
            //   fit: BoxFit.cover,
            // ),
            child: Lottie.asset('assets/LottieAssets/loan.zip'),
          ),
          SizedBox(
            height: 30,
          ),
          Center(
            child: Text(
              'Loans',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Item2 extends StatelessWidget {
  const Item2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 0.2 * height,
            width: 0.2 * width,
            // child: Image.asset(
            //   'assets/pics/savings-loan.png',
            //   fit: BoxFit.cover,
            // ),
            child: Lottie.asset('assets/LottieAssets/107877-onine-bank.zip'),
          ),
          Center(
            child: Text(
              'Buy and Pay Small Small',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0),
            ),
          ),
        ],
      ),
    );
  }
}

class Item3 extends StatelessWidget {
  const Item3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 0.2 * height,
            width: 0.2 * width,
            // child: Image.asset(
            //   'assets/pics/office_staff.jpg',
            //   fit: BoxFit.cover,
            // ),
            child: Lottie.asset('assets/LottieAssets/investment.zip'),
          ),
          Center(
            child: Text(
              'Fixed Deposit',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
            ),
          ),
        ],
      ),
    );
  }
}

class Item4 extends StatelessWidget {
  const Item4({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 0.2 * height,
            width: 0.2 * width,
            // child: Image.asset(
            //   'assets/pics/otp-new.png',
            //   fit: BoxFit.cover,
            // ),
            child: Lottie.asset(
                'assets/LottieAssets/11753-meda-chat-airtime-voucher-topup.zip'),
          ),
          Center(
            child: Text(
              'Savings Account',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
            ),
          ),
        ],
      ),
    );
  }
}

class Item5 extends StatelessWidget {
  const Item5({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 0.2 * height,
            width: 0.2 * height,
            // child: Image.asset(
            //   'assets/pics/core_bank.jpg',
            //   fit: BoxFit.cover,
            // ),
            child: Lottie.asset('assets/LottieAssets/accounting-report.zip'),
          ),
          Center(
            child: Text(
              'Corporate Account',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Item6 extends StatelessWidget {
  const Item6({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 0.2 * height,
            width: 0.2 * height,
            // child: Image.asset(
            //   'assets/pics/savings-loan.png',
            //   fit: BoxFit.cover,
            // ),
            child: Lottie.asset('assets/LottieAssets/kid.zip'),
          ),
          Center(
            child: Text(
              'Landmark Coop Rich Kids',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
            ),
          ),
        ],
      ),
    );
  }
}

class Item7 extends StatelessWidget {
  const Item7({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 0.2 * height,
            width: 0.2 * height,
            // child: Image.asset(
            //   'assets/pics/office_staff.jpg',
            //   fit: BoxFit.cover,
            // ),
            child: Lottie.asset('assets/LottieAssets/target.zip'),
          ),
          Center(
            child: Text(
              'Target Savings',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
            ),
          ),
        ],
      ),
    );
  }
}

class Item8 extends StatelessWidget {
  const Item8({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 0.2 * height,
            width: 0.2 * height,
            // child: Image.asset(
            //   'assets/pics/otp-new.png',
            //   fit: BoxFit.cover,
            // ),
            child: Lottie.asset(
                'assets/LottieAssets/atm-card.zip'),
          ),
          Center(
            child: Text(
              'ATM Cards',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
            ),
          ),
        ],
      ),
    );
  }
}
