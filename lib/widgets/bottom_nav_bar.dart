import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_latest/model/customer_model.dart';
import 'package:landmarkcoop_latest/pages/bottomPages/customer_care.dart';
import 'package:landmarkcoop_latest/pages/bottomPages/dashboard.dart';
import 'package:landmarkcoop_latest/pages/bottomPages/transfer_tabs.dart';


import '../pages/bottomPages/setting.dart';

class BottomNavBar extends StatefulWidget {
  final int pageIndex;
  final String fullName;
  final String token;
  final String phoneNumber;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final String subdomain;

  const BottomNavBar(
      {super.key,
      required this.pageIndex,
      required this.customerWallets,
      required this.fullName,
      required this.token,
      required this.phoneNumber,
        required this.subdomain,
      });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _selectedIndex;
  late List<Widget> _pages;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedIndex = widget.pageIndex;
    });
    _pages = <Widget>[
      Dashboard(
          pageIndex: 0,
          fullName: widget.fullName,
          token: widget.token,
          customerWallets: widget.customerWallets,),
      TransferTabs(
          pageIndex: 1,
          fullName: widget.fullName,
          token: widget.token,
          customerWallets: widget.customerWallets, subdomain: '',),
      Setting(
          pageIndex: 2,
          fullName: widget.fullName,
          token: widget.token,
          customerWallets: widget.customerWallets,
          phoneNumber: widget.phoneNumber),
      ContactCustomerSupport(
          pageIndex: 3,
          fullName: widget.fullName,
          token: widget.token,
          customerWallets: widget.customerWallets, referralId: widget.phoneNumber,),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 4.5,
        backgroundColor: Color.fromRGBO(49, 88, 203, 1.0),
        selectedFontSize: 15,
        selectedIconTheme:
            const IconThemeData(color: Colors.black, size: 15),
        selectedItemColor: Colors.black,
        selectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w300),
        unselectedFontSize: 15,
        unselectedIconTheme: const IconThemeData(color: Colors.grey),
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle:
            GoogleFonts.montserrat(fontWeight: FontWeight.w300),
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.arrow_up_right),
            label: 'Transfer',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.headphones),
            label: 'Help',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
