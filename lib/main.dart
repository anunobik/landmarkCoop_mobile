import 'package:landmarkcoop_mobile_app/pages/first_registration.dart';
import 'package:landmarkcoop_mobile_app/pages/login.dart';
import 'package:landmarkcoop_mobile_app/util/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'component/clipper_paint_design/curve_painter.dart';


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


void main() async{
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
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      String? token = await FirebaseMessaging.instance.getToken();
      print("The token is "+token!);
  } else {
      print('User declined or has not accepted permission');
    }
  runApp(const MobileBank());
}

class MobileBank extends StatelessWidget {
  const MobileBank({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
        theme: ThemeData.light().copyWith(
            textTheme:
                GoogleFonts.montserratTextTheme(Theme.of(context).textTheme)),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List cardList = [
    const Item1(),
    const Item2(),
    const Item3(),
    const Item4(),
  ];

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Column(
      children: [
        Column(
          children: [
            // const TopBar(),
            Container(
              height: height * 0.18,
            ),
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                  image: const DecorationImage(
                      image: AssetImage('assets/landmark.jpg'),
                      fit: BoxFit.contain)),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
            //   child: Center(
            //     child: Text('Landmark Coop.',
            //         textAlign: TextAlign.center,
            //         style: GoogleFonts.montserrat(
            //             color: Colors.black,
            //             fontSize: 18,
            //             fontWeight: FontWeight.bold)),
            //   ),
            // )
          ],
        ),
        Expanded(
          child: CarouselSlider(
            items: cardList.map((card) {
              return Builder(builder: (BuildContext context) {
                return SizedBox(
                  height: 0.45 * height,
                  width: width,
                  child: Card(
                    elevation: 5.0, // Add elevation for shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0), // Set border radius
                    ),
                    color: Colors.blue.shade800,
                    child: card,
                  ),
                );
              });
            }).toList(),
            carouselController: _controller,
            options: CarouselOptions(
              height: 350.8,
              autoPlay: true,
              enlargeCenterPage: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              pauseAutoPlayOnTouch: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: map<Widget>(cardList, ((index, url) {
            return Container(
              width: 12.0,
              height: 12.0,
              margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index
                    ? Colors.blueAccent
                    : Colors.black12,
              ),
            );
          }))),
        TextButton(
          onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const Login())),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.blue.shade800),
            )),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: width * 0.25, vertical: 12.0),
            child: Text(
              'Login',
              style: GoogleFonts.montserrat(
                  color: Colors.blue.shade800, fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
        const SizedBox(height: 20,),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const FirstRegistration()));
          },
          style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              primary: Colors.blue[500],
              textStyle: GoogleFonts.dmSans(fontSize: 15)),
          child: const Text('Open a New Account', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
        ),
        const SizedBox(height: 50,),
      ],
    ));
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return CustomPaint(
      painter: CurvePainter(),
      child: Container(
        height: height * 0.18,
      ),
    );
  }
}

class Item1 extends StatelessWidget {
  const Item1({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 0.25 * height,
            width: 0.25 * height,
            child: Lottie.asset('assets/112338-relax.zip'),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text(
                'Easy banking with the greatest of ease',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Item2 extends StatelessWidget {
  const Item2({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 0.25 * height,
            width: 0.25 * height,
            child: Lottie.asset('assets/6139-animacion-ted.zip'),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text(
                'Make a deposit into your account at your convenience',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Item3 extends StatelessWidget {
  const Item3({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 0.25 * height,
            width: 0.25 * height,
            child: Lottie.asset('assets/71841-mobile-investing.zip'),
          ),
          Text(
            'Wealth Education',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}

class Item4 extends StatelessWidget {
  const Item4({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 0.25 * height,
            width: 0.25 * height,
            child: Lottie.asset('assets/90204-planejador-financeiro.zip'),
          ),
          Text(
            'Ease investments',
            textAlign: TextAlign.center,
            style: GoogleFonts.raleway(
              textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
