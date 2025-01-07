import 'package:rive/rive.dart';

class RiveAsset {
  final String artboard, stateMachineName, title, src;
  late SMIBool? input;

  RiveAsset(
      {required this.src,
      required this.artboard,
      required this.stateMachineName,
      required this.title,
      this.input});

  set setInput(SMIBool status) {
    input = status;
  }
}

List<RiveAsset> sideMenus = [
  RiveAsset(
    src: 'assets/RiveAssets/icons1.riv',
    artboard: "HOME",
    stateMachineName: "HOME_interactivity",
    title: "Home",
  ),
  RiveAsset(
    src: 'assets/RiveAssets/icons1.riv',
    artboard: "TIMER",
    stateMachineName: "TIMER_Interactivity",
    title: "Statement",
  ),
];

// List<RiveAsset> sideMenus1 = [
//   RiveAsset(
//     src: 'assets/RiveAssets/pack.riv',
//     artboard: "download",
//     stateMachineName: "download_interactivity",
//     title: "Withdrawal",
//   ),
// ];

RiveAsset cableTv = RiveAsset(
  src: 'assets/RiveAssets/pack.riv',
  artboard: "download",
  stateMachineName: "download_interactivity",
  title: "Cable Tv",
);

RiveAsset transfer = RiveAsset(
  src: 'assets/RiveAssets/send_cash.riv',
  artboard: "Send Cash",
  stateMachineName: "Send Cash",
  title: "Transfer",
);

List<RiveAsset> sideMenus4 = [
  RiveAsset(
    src: 'assets/RiveAssets/icons1.riv',
    artboard: "REFRESH/RELOAD",
    stateMachineName: "RELOAD_Interactivity",
    title: "Investment",
  ),
  RiveAsset(
    src: 'assets/RiveAssets/icons1.riv',
    artboard: "SETTINGS",
    stateMachineName: "SETTINGS_Interactivity",
    title: "Settings",
  ),
  RiveAsset(
    src: 'assets/RiveAssets/icons1.riv',
    artboard: "CHAT",
    stateMachineName: "CHAT_Interactivity",
    title: "Contact Center",
  ),
  RiveAsset(
    src: 'assets/RiveAssets/icons1.riv',
    artboard: "BELL",
    stateMachineName: "BELL_Interactivity",
    title: "Notification",
  ),
];

RiveAsset logout = RiveAsset(
  src: 'assets/RiveAssets/switch.riv',
  artboard: "Switch",
  stateMachineName: "Switch",
  title: "Logout",
);

// RiveAsset lightBulb = RiveAsset(
//   src: 'assets/RiveAssets/light-bulb.riv',
//   artboard: "New Artboard",
//   stateMachineName: "bulb",
//   title: "Light Payment",
// );

List<RiveAsset> sideMenus3 = [
  RiveAsset(
    src: 'assets/RiveAssets/phone.riv',
    artboard: "device-phone-mobile",
    stateMachineName: "State Machine 1",
    title: "Airtime / Data",
  )
];

// RiveAsset tv = RiveAsset(
//   src: 'assets/RiveAssets/tv_machine.riv',
//   artboard: "New Artboard",
//   stateMachineName: "tv",
//   title: "TV Subscription",
// );

// List<RiveAsset> sideMenus2 = [
//   RiveAsset(
//     src: 'assets/RiveAssets/icon.riv',
//     artboard: "list 2",
//     stateMachineName: "State Machine 1",
//     title: "Bills Payment",
//   ),
// ];
