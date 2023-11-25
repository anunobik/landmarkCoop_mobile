import 'package:desalmcs_mobile_app/util/string_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TransferDetails extends StatefulWidget {
  final String narration;
  final String beneficiary;
  final String accountNumber;
  final String bank;
  final String amount;
  final String status;
  final String date;
  final String time;
  const TransferDetails({super.key, required this.narration, required this.beneficiary, required this.accountNumber, required this.bank, required this.amount, required this.status, required this.date, required this.time});

  @override
  State<TransferDetails> createState() => _TransferDetailsState();
}

class _TransferDetailsState extends State<TransferDetails> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Transfer Details',
          style: GoogleFonts.montserrat(
            color: const Color(0XFF091841),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              final imageLogo = await imageFromAssetBundle(
                "assets/pics/MinervaHub Logo.png",
              );
              final nairaLogo = await imageFromAssetBundle(
                "assets/pics/naira-lightBlue.png",
              );
              final doc = pw.Document();
              doc.addPage(pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) {
                return downloadDocument(imageLogo, nairaLogo);
              }));
              await Printing.sharePdf(
              bytes: await doc.save(),
              filename: 'transfer_receipt.pdf');
            }, 
            icon: const Icon(
              CupertinoIcons.share,
            )
          ),
        ],
        iconTheme: const IconThemeData(color: Color(0XFF091841)),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Container(
          padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.lightBlue
              )
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.status.capitalize(),
                  style: GoogleFonts.montserrat(
                    color: widget.status == 'successful' ? Colors.green
                    : widget.status == 'failed' ? Colors.red
                    : Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 26
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Send to',
                      style: GoogleFonts.montserrat(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: width * 0.4,
                      child: Text(
                        widget.beneficiary,
                        textAlign: TextAlign.end,
                        style: GoogleFonts.montserrat(
                          color: const Color(0xff000080),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Account number',
                      style: GoogleFonts.montserrat(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: width * 0.4,
                      child: Text(
                        widget.accountNumber,
                        textAlign: TextAlign.end,
                        style: GoogleFonts.montserrat(
                          color: const Color(0xff000080),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Bank',
                      style: GoogleFonts.montserrat(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: width * 0.4,
                      child: Text(
                        widget.bank,
                        textAlign: TextAlign.end,
                        style: GoogleFonts.montserrat(
                          color: const Color(0xff000080),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Amount',
                      style: GoogleFonts.montserrat(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: width * 0.4,
                      child: Text(
                        widget.amount,
                        textAlign: TextAlign.end,
                        style: GoogleFonts.montserrat(
                          color: const Color(0xff000080),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Remarks',
                      style: GoogleFonts.montserrat(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: width * 0.4,
                      child: Text(
                        widget.narration,
                        textAlign: TextAlign.end,
                        style: GoogleFonts.montserrat(
                          color: const Color(0xff000080),
                          fontWeight: FontWeight.bold,
                        ),
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
  // Download Widget

  downloadDocument(logoImage, logoNaira) {
    return pw.Column(children: <pw.Widget>[
      pw.SizedBox(height: 20),
      pw.Text(
        'Minerva Hub',
        style: pw.TextStyle(
          color: PdfColor.fromHex("#091841"),
          fontWeight: pw.FontWeight.bold,
          fontSize: 25.0,
        ),
      ),
      pw.Row(
        children: <pw.Widget>[
          pw.Image(
            logoImage,
            height: 100,
            width: 100,
          ),
          pw.SizedBox(width: 30),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Transfer Receipt!',
                style: pw.TextStyle(
                  color: PdfColors.lightBlue,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
            ],
          ),
        ],
      ),
      pw.Container(
        margin: const pw.EdgeInsets.all(20),
        padding: const pw.EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height * 0.62,
        width: MediaQuery.of(context).size.width,
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(20),
          border: pw.Border.all(
            color: PdfColors.lightBlue,
          ),
        ),
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Center(
                child: pw.Text(
                  'Transfer ${widget.status.capitalize()}',
                  style: pw.TextStyle(
                    color: PdfColor.fromHex("#000080"),
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw. Text(
                    'Amount',
                    style: pw.TextStyle(
                      color: PdfColors.lightBlue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: pw.Text(
                      'NGN${widget.amount}',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text(
                    'Date & Time',
                    style: pw.TextStyle(
                      color: PdfColors.lightBlue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: pw.Text(
                      '${widget.date} - ${widget.time}',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text(
                    'Beneficiary',
                    style: pw.TextStyle(
                      color: PdfColors.lightBlue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.RichText(
                    text: pw.TextSpan(
                      text: widget.beneficiary,
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      children: <pw.TextSpan>[
                        pw.TextSpan(
                          text: widget.accountNumber,
                          style: const pw.TextStyle(),
                        ),
                        const pw.TextSpan(
                          text: '\n',
                          style: pw.TextStyle(),
                        ),
                        pw.TextSpan(
                          text: widget.bank,
                          style: const pw.TextStyle(),
                        ),
                      ]
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text(
                    'Sender',
                    style: pw.TextStyle(
                      color: PdfColors.lightBlue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Jackson Anana',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text(
                    'Transfer fee',
                    style: pw.TextStyle(
                      color: PdfColors.lightBlue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'free',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                children: <pw.Widget>[
                  pw.Text(
                    'Remark',
                    style: pw.TextStyle(
                      color: PdfColors.lightBlue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Spacer(),
                  pw.SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: pw.Text(
                      widget.narration,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text(
                    'Session Id',
                    style: pw.TextStyle(
                      color: PdfColors.lightBlue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: pw.Text(
                      '100026230325120547000031398651',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Disclaimer:\n',
                    style: pw.TextStyle(
                      color: PdfColors.black,
                      fontWeight: pw.FontWeight.bold
                    ),
                    children: const <pw.TextSpan>[
                      pw.TextSpan(
                        text: 'OZI has successfully processed this transaction but the completion of the transfers are subject to transaction errors, network interruptions, glitches and other factors that are beyond OZI\'s control and for which OZI will not be liable. If any issues are experienced with your transaction, please generate a receipt from the list of recent transactions',
                        style: pw.TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ]
                  ),
                  textAlign: pw.TextAlign.justify,
                ),
              ),
              pw.SizedBox(height: 40),
            ]
          ),
        ),
      ]
    );
  }
}