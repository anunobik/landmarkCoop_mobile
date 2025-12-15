import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_latest/model/rive_asset.dart';
import 'package:rive/rive.dart';

class SideMenuTile extends StatelessWidget {
  const SideMenuTile({
    Key? key,
    required this.menu,
    required this.press,
    required this.riveonInit,
    required this.isActive,
  }) : super(key: key);

  final RiveAsset menu;
  final VoidCallback press;
  final ValueChanged<Artboard> riveonInit;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(left: 24.0),
          child: Divider(
            height: 1,
            color: Colors.lightBlue,
          ),
        ),
        Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              height: 56,
              width: isActive ? 288 : 0,
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            ListTile(
              onTap: press,
              leading: SizedBox(
                height: 34,
                width: 34,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.lightBlue, // Change this to the desired color
                    BlendMode.modulate, // Use BlendMode to control color effect
                  ),
                  child: RiveAnimation.asset(
                    menu.src,
                    artboard: menu.artboard,
                    onInit: riveonInit,
                  ),
                ),
              ),
              title: Text(
                menu.title,
                style: GoogleFonts.montserrat(
                  color: Color(0xff000080),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
