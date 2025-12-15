import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_latest/api/api_service.dart';
import 'package:landmarkcoop_latest/component/side_menu_tile.dart';
import 'package:landmarkcoop_latest/entry_point.dart';
import 'package:landmarkcoop_latest/model/customer_model.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/rive_asset.dart';
import '../utils/rive_utils.dart';
import 'info_card.dart';

class SideMenu extends StatefulWidget {
  final String fullName;
  final String subdomain;
  final String token;
  final String referralId;
  final List<CustomerWalletsBalanceModel> customerWallets;

  const SideMenu({
    super.key, 
    required this.fullName, 
    required this.subdomain, 
    required this.token, 
    required this.customerWallets,
    required this.referralId,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String selectedMenu = "Home";
  // late SMIBool onPress;
  late SMITrigger onTrigger;
  late SMITrigger trigger;
  late SMITrigger onTrig;
  bool isMinervaHub = false;

  Future<void> checkFintech() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';
    String institution = prefs.getString('institution') ?? 'Minerva Hub';
    if (institution == 'Landmark Coop' ||
        institution.isEmpty) {
      isMinervaHub = true;
    }
  }
  
  @override
  void initState() {
    checkFintech();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        width: 288,
        color: Colors.white,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                InfoCard(
                  fullName: widget.fullName,
                  subdomain: widget.subdomain,
                ),
                const SizedBox(height: 20),

                // Side Menu 
                ...sideMenus.map((menu) => SideMenuTile(
                    menu: menu,
                    riveonInit: (artboard) {
                      StateMachineController controller = RiveUtils.getRiveController(
                        artboard, stateMachineName: menu.stateMachineName,
                      );
                      menu.input = controller.findSMI("active") as SMIBool;
                    },
                    press: () {
                      menu.input!.change(true);
                      Future.delayed(
                        const Duration(seconds: 1), () {
                          menu.input!.change(false);
                        }
                      );
                      setState(() {
                        selectedMenu = menu.title;
                      });
                      Future.delayed(
                        const Duration(seconds: 1), () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => EntryPoint(
                              screenName: menu.title, 
                              fullName: widget.fullName, 
                              subdomain: widget.subdomain,
                               token: widget.token, 
                               customerWallets: widget.customerWallets, referralId: widget.referralId,
                              ),
                            )
                          );
                        }
                      );
                    },
                    isActive: selectedMenu == menu.title,
                  ),
                ),

                // Side Menu 1
                // ...sideMenus1.map((menu) => SideMenuTile(
                //     menu: menu,
                //     riveonInit: (artboard) {
                //       StateMachineController controller = RiveUtils.getRiveController(
                //         artboard, stateMachineName: menu.stateMachineName,
                //       );
                //       menu.input = controller.findSMI("active") as SMIBool;
                //     },
                //     press: () {
                //       menu.input!.change(true);
                //       Future.delayed(
                //         const Duration(seconds: 1), () {
                //           menu.input!.change(false);
                //         }
                //       );
                //       setState(() {
                //         selectedMenu = menu.title;
                //       });
                //       Future.delayed(
                //         const Duration(seconds: 1), () {
                //           Navigator.of(context).pushReplacement(
                //             MaterialPageRoute(builder: (context) => EntryPoint(
                //               screenName: menu.title,
                //               fullName: widget.fullName,
                //               subdomain: widget.subdomain,
                //                token: widget.token,
                //                customerWallets: widget.customerWallets, referralId: widget.referralId,
                //               ),
                //             ),
                //           );
                //         }
                //       );
                //     },
                //     isActive: selectedMenu == menu.title,
                //   ),
                // ),

                // Cable Tv
                SideMenuTile(
                  menu: cableTv,
                  riveonInit: (artboard) {
                    StateMachineController controller = RiveUtils.getRiveController(artboard, stateMachineName: 'download_interactivity');
                    onTrig = controller.findSMI("Hover/Press") as SMITrigger;
                  },
                  press: () {
                    Future.delayed(
                      const Duration(seconds: 1), () {
                        onTrig.change(true);
                      }
                    );
                    Future.delayed(
                      const Duration(seconds: 2), () {
                        onTrig.change(false);
                      }
                    );
                    setState(() {
                      selectedMenu = "Cable Tv";
                    });
                    Future.delayed(
                      const Duration(seconds: 2), () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => EntryPoint(
                            screenName: cableTv.title,
                            fullName: widget.fullName,
                            subdomain: widget.subdomain,
                              token: widget.token,
                              customerWallets: widget.customerWallets, referralId: widget.referralId,
                            ),
                          ),
                        );
                      }
                    );
                  },
                  isActive: selectedMenu == "Cable Tv",
                ),


                // Side Menu 3
                 ...sideMenus3.map((menu) => SideMenuTile(
                    menu: menu,
                    riveonInit: (artboard) {
                      StateMachineController controller = RiveUtils.getRiveController(
                        artboard, stateMachineName: menu.stateMachineName,
                      );
                      menu.input = controller.findSMI("hover") as SMIBool;
                    },
                    press: () {
                      menu.input!.change(true);
                      Future.delayed(
                        const Duration(seconds: 1), () {
                          menu.input!.change(false);
                        }
                      );
                      setState(() {
                        selectedMenu = menu.title;
                      });
                      Future.delayed(
                        const Duration(seconds: 2), () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => EntryPoint(
                              screenName: menu.title,
                              fullName: widget.fullName,
                              subdomain: widget.subdomain,
                                token: widget.token,
                                customerWallets: widget.customerWallets, referralId: widget.referralId,
                              ),
                            ),
                          );
                        }
                      );
                    },
                    isActive: selectedMenu == menu.title,
                  ),
                ),


                // Transfer
                SideMenuTile(
                  menu: transfer, 
                  riveonInit: (artboard) {
                    StateMachineController controller = RiveUtils.getRiveController(artboard, stateMachineName: 'Send Cash');
                    trigger = controller.findSMI("Hover/Press") as SMITrigger;
                  },
                  press: () {
                    Future.delayed(
                      const Duration(seconds: 1), () {
                        trigger.change(true);
                      }
                    );
                    Future.delayed(
                      const Duration(seconds: 2), () {
                        trigger.change(false);
                      }
                    );
                    setState(() {
                      selectedMenu = "Transfer";
                    });
                    Future.delayed(
                      const Duration(seconds: 2), () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => EntryPoint(
                            screenName: transfer.title,
                            fullName: widget.fullName, 
                            subdomain: widget.subdomain,
                            token: widget.token, 
                            customerWallets: widget.customerWallets, referralId: widget.referralId,
                            ),
                          ),
                        );
                      }
                    );
                  },
                  isActive: selectedMenu == "Transfer",
                ),


                // Side Menu 4
                ...sideMenus4.map((menu) => SideMenuTile(
                    menu: menu,
                    riveonInit: (artboard) {
                      StateMachineController controller = RiveUtils.getRiveController(
                        artboard, stateMachineName: menu.stateMachineName,
                      );
                      menu.input = controller.findSMI("active") as SMIBool;
                    },
                    press: () {
                      menu.input!.change(true);
                      Future.delayed(
                        const Duration(seconds: 1), () {
                          menu.input!.change(false);
                        }
                      );
                      setState(() {
                        selectedMenu = menu.title;
                      });
                      Future.delayed(
                        const Duration(seconds: 1), () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => EntryPoint(
                              screenName: menu.title, 
                              fullName: widget.fullName, 
                              subdomain: widget.subdomain,
                              token: widget.token, 
                              customerWallets: widget.customerWallets,
                              referralId: widget.referralId,
                              ),
                            ),
                          );
                        }
                      );
                    },
                    isActive: selectedMenu == menu.title,
                  ),
                ),
                
                // Logout
                SideMenuTile(
                  menu: logout, 
                  riveonInit: (artboard) {
                    StateMachineController controller = RiveUtils.getRiveController(artboard, stateMachineName: 'Switch');
                    onTrigger = controller.findSMI("Pressed") as SMITrigger;
                  },
                  press: () {
                    Future.delayed(
                      const Duration(seconds: 1), () {
                        onTrigger.change(true);
                      }
                    );
                    Future.delayed(
                      const Duration(seconds: 2), () {
                        onTrigger.change(false);
                      }
                    );
                    setState(() {
                      selectedMenu = "Logout";
                    });
                    Future.delayed(
                      const Duration(seconds: 2), () async{
                        Navigator.pushReplacement(context, 
                        MaterialPageRoute(builder: (context) => EntryPoint(
                          screenName: logout.title, 
                          fullName: widget.fullName, 
                          subdomain: widget.subdomain,
                          token: widget.token, 
                          customerWallets: widget.customerWallets,
                          referralId: widget.referralId,
                          ))
                        );
                      }
                    );
                  },
                  isActive: selectedMenu == "Logout",
                ),
                // const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    const SizedBox(width: 15),
                    RichText(
                      text: TextSpan(
                        text: 'Referral Code:  ',
                        style: GoogleFonts.montserrat(
                          color: Color(0xff000080),
                          fontWeight: FontWeight.w500,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: widget.referralId,
                            style: GoogleFonts.montserrat(
                              color: Color(0xff000080),
                              fontSize: 10,
                              // fontWeight: FontWeight.w600,
                            ),
                          ),
                        ]
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: widget.referralId,
                          )
                        ).then((value) => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.lightBlue,
                            content: Text(
                              'copied to clipboard',
                              style: GoogleFonts.openSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          )
                        );
                      },
                      icon: const Icon(
                        Icons.content_copy_rounded,
                        color: Color(0xff000080),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




// Light Bulb
// SideMenuTile(
//   menu: lightBulb, 
//   riveonInit: (artboard) {
//     StateMachineController controller = RiveUtils.getRiveController(artboard, stateMachineName: 'bulb');
//     onPress = controller.findSMI("pressed") as SMIBool;
//   },
//   press: () {
//     Future.delayed(
//       const Duration(seconds: 1), () {
//         onPress.change(false);
//       }
//     );
//     Future.delayed(
//       const Duration(seconds: 2), () {
//         onPress.change(true);
//       }
//     );
//     setState(() {
//         selectedMenu = "Light Payment";
//       });
//   },
//   isActive: selectedMenu == "Light Payment",
// ),
// keytool -genkey -v -keyalg RSA -keysize 2048 -storetype JKS -keystore C:\Users\DELL\StudioProjects\landmarkcoop_mobile\landmarkcoop.jks -validity 10000 -alias upload

