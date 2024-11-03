import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../model/customer_model.dart';
import '../model/other_model.dart';
import 'package:intl/intl.dart';

class TransferReceipt extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final ExternalBankTransferDetailsRequestModel externalBankTransferDetailsRequestModel;


  const TransferReceipt({
    super.key,
    required this.customerWallets,
    required this.fullName,
    required this.token,
    required this.externalBankTransferDetailsRequestModel,
  });

  @override
  State<TransferReceipt> createState() => _TransferReceiptState();
}

class _TransferReceiptState extends State<TransferReceipt> {
  final displayAmount = NumberFormat("#,##0.00", "en_US");
  String datePart = DateFormat('dd-MMM-yyyy hh:mm a').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Receipt',
          style: GoogleFonts.montserrat(
            color: const Color(0XFF091841),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final imageLogo = await imageFromAssetBundle(
                "assets/pics/Logo.png",
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
              CupertinoIcons.share
            ),
          )
        ],
        iconTheme: const IconThemeData(color: Color(0XFF091841),),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 100,
                  width: 100,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/pics/Logo.png"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(10),
                height: height * 0.62,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.lightBlue,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Text(
                          'Transfer Successful',
                          style: GoogleFonts.montserrat(
                            color: const Color(0xff000080),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
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
                            width: width * 0.6,
                            child: Text(
                              '₦${displayAmount.format(int.parse(widget.externalBankTransferDetailsRequestModel.amount))}',
                              textAlign: TextAlign.end,
                              style: GoogleFonts.montserrat(
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
                            'Date & Time',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: width * 0.6,
                            child: Text(
                              datePart,
                              textAlign: TextAlign.end,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Beneficiary',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: widget.externalBankTransferDetailsRequestModel.destinationAccountName,
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '\n',
                                  style: GoogleFonts.montserrat(),
                                ),
                                TextSpan(
                                  text: widget.externalBankTransferDetailsRequestModel.destinationAccountNumber,
                                  style: GoogleFonts.montserrat(),
                                ),
                                TextSpan(
                                  text: '\n',
                                  style: GoogleFonts.montserrat(),
                                ),
                                TextSpan(
                                  text: widget.externalBankTransferDetailsRequestModel.destinationBankName,
                                  style: GoogleFonts.montserrat(),
                                ),
                              ]
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Sender',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.fullName,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Transfer fee',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'FREE',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Text(
                            'Narration',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: width * 0.6,
                            child: Text(
                              widget.externalBankTransferDetailsRequestModel.narration,
                              textAlign: TextAlign.end,
                              style: GoogleFonts.montserrat(
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
                            'Reference No',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: width * 0.1,
                              maxWidth: width * 0.5,
                            ),
                            width: width * 0.5,
                            child: Text(
                              widget.externalBankTransferDetailsRequestModel.reference,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: GoogleFonts.montserrat(
                                // fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Disclaimer:\n',
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Landmark has successfully processed this transaction but the completion of the transfers are subject to transaction errors, network interruptions, glitches and other factors that are beyond Landmark\'s control and for which Landmark will not be liable. If any issues are experienced with your transaction, please generate a receipt from the list of recent transactions',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                ),
                              ),
                            ]
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
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
                  'Transfer Successful',
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
                      'NGN${displayAmount.format(int.parse(widget.externalBankTransferDetailsRequestModel.amount))}',
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
                      datePart,
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
                      text: widget.externalBankTransferDetailsRequestModel.destinationAccountName,
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      children: <pw.TextSpan>[
                        const pw.TextSpan(
                          text: '\n',
                          style: pw.TextStyle(),
                        ),
                        pw.TextSpan(
                          text: widget.externalBankTransferDetailsRequestModel.destinationAccountNumber,
                          style: const pw.TextStyle(),
                        ),
                        const pw.TextSpan(
                          text: '\n',
                          style: pw.TextStyle(),
                        ),
                        pw.TextSpan(
                          text: widget.externalBankTransferDetailsRequestModel.destinationBankName,
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
                    widget.fullName,
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
                    'FREE',
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
                    'Narration',
                    style: pw.TextStyle(
                      color: PdfColors.lightBlue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Spacer(),
                  pw.SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: pw.Text(
                      widget.externalBankTransferDetailsRequestModel.narration,
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
                    'Reference No.',
                    style: pw.TextStyle(
                      color: PdfColors.lightBlue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: pw.Text(
                      widget.externalBankTransferDetailsRequestModel.reference,
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
                        text: 'Landmark has successfully processed this transaction but the completion of the transfers are subject to transaction errors, network interruptions, glitches and other factors that are beyond Landmark\'s control and for which Landmark will not be liable. If any issues are experienced with your transaction, please generate a receipt from the list of recent transactions',
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