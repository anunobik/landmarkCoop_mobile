import 'package:landmarkcoop_mobile_app/pages/transfer_details.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../util/status_list.dart';

Future<Object?> searchStatus(BuildContext context,
  {required ValueChanged onClosed}){
    var width = MediaQuery.of(context).size.width;
    TextEditingController searchController = TextEditingController();
    List searchList = [];
    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: 'Search Transfer Status',
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, __, child) {
        Tween<Offset> tween;
        tween = Tween(begin: const Offset(0, -1), end: Offset.zero);
        return SlideTransition(
          position: tween.animate(CurvedAnimation(
            parent: animation, 
            curve: Curves.easeInOut,
            ),
          ),
          child: child,
        );
      },
      context: context, 
      pageBuilder: (context, _, __) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          void onSearchItem(value) {
            setState(() {
              searchList = statusList.where((element) => element.toString().toLowerCase().contains(value.toString().toLowerCase())).toList();
            });
          }
          return Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              height: 620,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(40)),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      children: [
                        Text('Search Transfer Status',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          )
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            SizedBox(
                              width: width * 0.55,
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                controller: searchController,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Search',
                                  hintStyle: GoogleFonts.montserrat(
                                    color: const Color(0xff9ca2ac),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: onSearchItem,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    searchController.text = '';
                                    searchList = [];
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                                child: Text(
                                  'Clear',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                        searchList.isNotEmpty & searchController.text.isNotEmpty ? Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: searchList.length,
                            cacheExtent: 0,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 13.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => TransferDetails(
                                        accountNumber: searchList[index]['account_number'].toString(), 
                                        amount: "₦${searchList[index]['amount']}", bank: searchList[index]['bank'].toString(), 
                                        beneficiary: searchList[index]['beneficiary'].toString(),
                                        narration: searchList[index]['narration'].toString(),status: searchList[index]['status'].toString(), 
                                        date: searchList[index]['date'].toString(), 
                                        time: searchList[index]['time'].toString(),
                                        )
                                      )
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(4, 4),
                                          color: Colors.grey.shade200,
                                          blurRadius: 4,
                                          spreadRadius: 2
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.outbond_outlined,
                                          color: searchList[index]['status'].toString() == 'successful' ? Colors.green
                                          : searchList[index]['status'].toString() == 'failed' ?  Colors.red
                                          : Colors.amber,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(searchList[index]['beneficiary'].toString(),
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w700
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            Text(searchList[index]['narration'].toString(),
                                            maxLines: 3,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text("₦${searchList[index]['amount']}",
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w700
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            Text(searchList[index]['date'].toString(),maxLines: 2,
                                              style: GoogleFonts.montserrat(
                                                color: Colors.grey,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        : searchList.isEmpty & searchController.text.isNotEmpty ? Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Text('No Match Found',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 24
                            ),
                          ),
                        )
                        : statusList.isNotEmpty ? Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: statusList.length,
                            cacheExtent: 0,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 13.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => TransferDetails(
                                        accountNumber: statusList[index]['account_number'].toString(), 
                                        amount: "₦${statusList[index]['amount']}", bank: statusList[index]['bank'].toString(), 
                                        beneficiary: statusList[index]['beneficiary'].toString(),
                                        narration: statusList[index]['narration'].toString(),status: statusList[index]['status'].toString(), 
                                        date: statusList[index]['date'].toString(), 
                                        time: statusList[index]['time'].toString(),
                                        )
                                      )
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(4, 4),
                                          color: Colors.grey.shade200,
                                          blurRadius: 4,
                                          spreadRadius: 2
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.outbond_outlined,
                                          color: statusList[index]['status'].toString() == 'successful' ? Colors.green
                                          : statusList[index]['status'].toString() == 'failed' ?  Colors.red
                                          : Colors.amber,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(statusList[index]['beneficiary'].toString(),
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w700
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            Text(statusList[index]['narration'].toString(),
                                            maxLines: 3,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text("₦${statusList[index]['amount']}",
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w700
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            Text(statusList[index]['date'].toString(),maxLines: 2,
                                              style: GoogleFonts.montserrat(
                                                color: Colors.grey,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        : Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Text('You have not made any transfers yet',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 24
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: -48,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                      )
                    )
                  ],
                ),
              ),
            ),
          );
        }
    ),
  ).then((onClosed));
}