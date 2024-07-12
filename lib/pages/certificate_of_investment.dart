import 'package:auto_size_text/auto_size_text.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class CertificateOfInvestment extends StatefulWidget {
  final CustomerInvestmentWalletModel customerInvestmentWalletModel;

  const CertificateOfInvestment({
    Key? key,
    required this.customerInvestmentWalletModel,
  }) : super(key: key);

  @override
  State<CertificateOfInvestment> createState() =>
      _CertificateOfInvestmentState();
}

class _CertificateOfInvestmentState extends State<CertificateOfInvestment> {
  final displayAmount = NumberFormat("#,##0.00", "en_US");
  late String instruction;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    switch (widget.customerInvestmentWalletModel.instruction) {
      case 1:
        instruction = 'Roll-Over Principal Only and Redeem Interest';
        break;
      case 2:
        instruction = 'Roll-Over Principal and Interest';
        break;
      case 3:
        instruction = 'Redeem Principal and Interest';
        break;
      case 4:
        instruction = 'Interest drops monthly';
        break;
      default:
        instruction = 'Interest drops monthly';
        break;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Investment Certificate',
          style: GoogleFonts.montserrat(
            color: const Color(0xff091841),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xff091841),
        ),
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
                      image: AssetImage("assets/lg1.png"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
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
                          widget.customerInvestmentWalletModel.fullName,
                          style: GoogleFonts.montserrat(
                            color: const Color(0xff091841),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          AutoSizeText(
                            'Amount Booked:',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AutoSizeText(
                            displayAmount.format(
                                widget.customerInvestmentWalletModel.amount),
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
                          AutoSizeText(
                            'Investment Date:',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AutoSizeText(
                            widget.customerInvestmentWalletModel.timeCreated
                                .substring(0, 10),
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
                          AutoSizeText(
                            'Rate (%):',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AutoSizeText(
                            widget.customerInvestmentWalletModel.rate
                                .toString(),
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
                          AutoSizeText(
                            'Tenor (Months):',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AutoSizeText(
                            widget.customerInvestmentWalletModel.tenor
                                .toString(),
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
                          AutoSizeText(
                            'Interest Accrued:',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AutoSizeText(
                            displayAmount.format(
                                widget.customerInvestmentWalletModel.interest),
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          AutoSizeText(
                            'WHT:',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          AutoSizeText(
                            displayAmount.format(
                                widget.customerInvestmentWalletModel.wht),
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
                          AutoSizeText(
                            'Amount at Maturity:',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AutoSizeText(
                            displayAmount.format(widget
                                .customerInvestmentWalletModel.maturityAmount),
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
                          AutoSizeText(
                            'Maturity Date:',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AutoSizeText(
                            widget.customerInvestmentWalletModel.maturityTime
                                .substring(0, 10),
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
                          AutoSizeText(
                            'Instructions:',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Flexible(
                            child: AutoSizeText(
                              instruction,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                            'The package alternates 7days rollover or 30days cash out option upon maturity kindly note that, non-circle completed investment portfolio are disbursed under premature disbursement condition which attract 10% compulsory service charge and other incidental '
                            'recovery{s} as the case may be.', textAlign: TextAlign.justify,),
                      ),
                      const SizedBox(height: 10),
                      const SizedBox(height: 35),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final imageLogo = await imageFromAssetBundle(
                              "assets/lg1.png",
                            );
                            final nairaLogo = await imageFromAssetBundle(
                              "assets/naira-lightBlue.png",
                            );
                            final doc = pw.Document();
                            doc.addPage(pw.Page(
                                pageFormat: PdfPageFormat.a4,
                                build: (pw.Context context) {
                                  return downloadDocument(imageLogo, nairaLogo);
                                }));
                            await Printing.sharePdf(
                                bytes: await doc.save(),
                                filename: 'investment_certificate.pdf');
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(color: Colors.white),
                              ),
                              textStyle: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                          icon: const Padding(
                            padding: EdgeInsets.fromLTRB(20, 15, 0, 15),
                            child: Icon(
                              Icons.ios_share_outlined,
                            ),
                          ),
                          label: const Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 20, 15),
                            child: Text('Share'),
                          ),
                        ),
                      )
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
        'Landmark Coop',
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
                'Investment Certificate!',
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
        padding: const pw.EdgeInsets.all(20),
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
                  widget.customerInvestmentWalletModel.fullName,
                  style: pw.TextStyle(
                    color: PdfColor.fromHex('#091841'),
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text(
                    'Amount Booked:',
                    style: pw.TextStyle(
                      color: PdfColors.lightBlue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    displayAmount
                        .format(widget.customerInvestmentWalletModel.amount),
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
                    'Investment Date:',
                    style: pw.TextStyle(
                      color: PdfColors.lightBlue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    widget.customerInvestmentWalletModel.timeCreated
                        .substring(0, 10),
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
                    'Rate (%):',
                    style: pw.TextStyle(
                      color: PdfColors.lightBlue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    widget.customerInvestmentWalletModel.rate.toString(),
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
                    'Tenor (Months):',
                    style: pw.TextStyle(
                      color: PdfColors.lightBlue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    widget.customerInvestmentWalletModel.tenor.toString(),
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
                    'Interest Accrued:',
                    style: pw.TextStyle(
                      color: PdfColors.lightBlue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    displayAmount
                        .format(widget.customerInvestmentWalletModel.interest),
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
                    'WHT:',
                    style: pw.TextStyle(
                      color: PdfColors.lightBlue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    displayAmount
                        .format(widget.customerInvestmentWalletModel.wht),
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
                    'Amount at Maturity:',
                    style: pw.TextStyle(
                      color: PdfColors.lightBlue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    displayAmount.format(
                        widget.customerInvestmentWalletModel.maturityAmount),
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
                    'Maturity Date:',
                    style: pw.TextStyle(
                      color: PdfColors.lightBlue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    widget.customerInvestmentWalletModel.maturityTime
                        .substring(0, 10),
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
                    'Instructions:',
                    style: pw.TextStyle(
                      color: PdfColors.lightBlue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(width: 15),
                  pw.Flexible(
                    child: pw.Text(
                      instruction,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: pw.TextOverflow.clip,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
            ]),
      ),
      pw.Center(
        child: pw.Text(
            'The package alternates 7days rollover or 30days cash out option upon maturity kindly note that, non-circle completed investment portfolio are disbursed under premature disbursement condition which attract 10% compulsory service charge and other incidental '
            'recovery{s} as the case may be.', textAlign: pw.TextAlign.justify,),
      ),
      pw.SizedBox(height: 20),
    ]);
  }
}
