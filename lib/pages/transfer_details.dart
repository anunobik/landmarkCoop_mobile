import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/utils/string_extension.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';

import '../model/customer_model.dart';

class TransferDetails extends StatefulWidget {
  final String narration;
  final String beneficiary;
  final String accountNumber;
  final String bank;
  final String amount;
  final String status;
  final String date;
  final String time;
  final String fullName;
  final List<CustomerWalletsBalanceModel> customerWallets;

  const TransferDetails({super.key, required this.customerWallets,
    required this.fullName, required this.narration, required this.beneficiary, required this.accountNumber, required this.bank, required this.amount, required this.status, required this.date, required this.time});

  @override
  State<TransferDetails> createState() => _TransferDetailsState();
}

class _TransferDetailsState extends State<TransferDetails> {
  final displayAmount = NumberFormat("#,##0.00", "en_US");
  String datePart = DateFormat('dd-MMM-yyyy hh:mm a').format(DateTime.now());

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
            color: Color(0xff000080),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final imageLogo = await imageFromAssetBundle(
                "assets/Logo.png",
              );
              final nairaLogo = await imageFromAssetBundle(
                "assets/pics/naira-lightBlue.png",
              );

              // Show a dialog to let the user choose the file format
              final format = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Choose File Format"),
                    content: const Text("Would you like to save the receipt as a PDF or an Image?"),
                    actions: [
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Center the buttons
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, "PDF");
                              },
                              child: const Text("PDF"),
                            ),
                            const SizedBox(width: 20), // Add spacing between buttons
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, "JPG");
                              },
                              child: const Text("Image"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );

              if (format == "PDF") {
                // Generate and share the PDF
                final doc = pw.Document();
                doc.addPage(pw.Page(
                    pageFormat: PdfPageFormat.a4,
                    build: (pw.Context context) {
                      return downloadDocument(imageLogo, nairaLogo);
                    }));
                await Printing.sharePdf(
                    bytes: await doc.save(), filename: 'transfer_receipt.pdf');
              } else if (format == "JPG") {

                // Draw the document as an image (adjust as per your downloadDocument logic)
                downloadDocumentAsImage('assets/Logo.png');
              }
            },
            icon: const Icon(CupertinoIcons.share),
          )
        ],
        iconTheme: const IconThemeData(color: Color(0xff01440a)),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Container(
          padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.lightGreen
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
                    : Colors.blue,
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
                        color: Colors.lightGreen,
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
                        color: Colors.lightGreen,
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
                        color: Colors.lightGreen,
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
                        color: Colors.lightGreen,
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
                        color: Colors.lightGreen,
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

  downloadDocument(logoImage, logoNaira) {
    return pw.Center(
      child: pw.Column(children: <pw.Widget>[
        pw.SizedBox(height: 20),
        pw.Image(
          logoImage,
          height: 50,
          width: 50,
        ),
        pw.Text(
          'Landmark Coop',
          style: pw.TextStyle(
            color: PdfColors.blue,
            fontWeight: pw.FontWeight.bold,
            fontSize: 25.0,
          ),
        ),
        pw.Text(
          'Transfer Receipt!',
          style: pw.TextStyle(
            color: PdfColor.fromHex("#000080"),
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 30),
        pw.Container(
          // margin: const pw.EdgeInsets.all(5),
          // padding: const pw.EdgeInsets.all(5),
          height: MediaQuery.of(context).size.height * 0.62,
          width: MediaQuery.of(context).size.width,
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Center(
                  child: pw.Text(
                    'Transfer Successful',
                    style: pw.TextStyle(
                      color: PdfColors.lightGreen,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: <pw.Widget>[
                    pw.Text(
                      'Amount',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex("#000080"),
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: pw.Text('NGN${widget.amount}',
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(
                  color: PdfColors.black,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: <pw.Widget>[
                    pw.Text(
                      'Date',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex("#000080"),
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
                pw.SizedBox(height: 10),
                pw.Divider(
                  color: PdfColors.black,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: <pw.Widget>[
                    pw.Text(
                      'Beneficiary',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex("#000080"),
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
                            const pw.TextSpan(
                              text: '\n',
                              style: pw.TextStyle(),
                            ),
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
                          ]),
                      textAlign: pw.TextAlign.right,
                      maxLines: 3,  // Limit the number of lines
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(
                  color: PdfColors.black,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: <pw.Widget>[
                    pw.Text(
                      'Sender',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex("#000080"),
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
                pw.SizedBox(height: 10),
                pw.Divider(
                  color: PdfColors.black,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                ),
                pw.SizedBox(height: 10),
                pw.Divider(
                  color: PdfColors.black,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: <pw.Widget>[
                    pw.Text(
                      'Narration',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex("#000080"),
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
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.RichText(
                    text: pw.TextSpan(
                        text: 'Disclaimer:\n',
                        style: pw.TextStyle(
                            color: PdfColors.black,
                            fontWeight: pw.FontWeight.bold),
                        children: const <pw.TextSpan>[
                          pw.TextSpan(
                            text:
                            'Landmark Coop has successfully processed this transaction but the completion of the transfers are subject to transaction errors, network interruptions, glitches and other factors that are beyond Landmark Coop\'s control and for which Landmark Coop will not be liable. If any issues are experienced with your transaction, please generate a receipt from the list of recent transactions',
                            style: pw.TextStyle(
                              fontSize: 8,
                            ),
                          ),
                        ]),
                    textAlign: pw.TextAlign.justify,
                  ),
                ),
                pw.SizedBox(height: 40),
              ]),
        ),
      ]),
    );
  }

  // Function to load an image from assets as a dart:ui.Image
  Future<ui.Image> loadImageFromAsset(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final List<int> bytes = data.buffer.asUint8List();
    final ui.Image image = await decodeImageFromList(Uint8List.fromList(bytes));
    return image;
  }

  Future<void> downloadDocumentAsImage(String logoImageAsset) async {
    const double canvasWidth = 800;
    const double canvasHeight = 1200;
    const double padding = 150;
    const double logoSize = 100;
    const double gapBetweenLineAndWidget = 10; // Vertical gap between line and widget
    const double rowSpacing = 60; // Adjusted row spacing to include line gap

    final paint = Paint()..blendMode = BlendMode.src; // Ensure proper rendering

    // Load the logo as ui.Image
    final ui.Image logoImage = await loadImageFromAsset(logoImageAsset);

    // Create the canvas
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasWidth, canvasHeight));

    // Draw white background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, canvasWidth, canvasHeight),
      Paint()..color = const Color(0xFFFFFFFF), // White background
    );

    // Centered logo with white background
    final double logoX = (canvasWidth - logoSize) / 2;
    final double logoY = padding;

    // Draw white rectangle behind the logo (ensures no transparency issues)
    canvas.drawRect(
      Rect.fromLTWH(logoX, logoY, logoSize, logoSize),
      Paint()..color = const Color(0xFFFFFFFF), // White background for logo
    );

    // Draw the logo
    canvas.drawImageRect(
      logoImage,
      Rect.fromLTWH(0, 0, logoImage.width.toDouble(), logoImage.height.toDouble()),
      Rect.fromLTWH(logoX, logoY, logoSize, logoSize),
      paint,
    );

    // Centered logo name
    final titleTextStyle = TextStyle(
      color: const Color(0xFFFFA000), // Amber
      fontSize: 25,
      fontWeight: FontWeight.bold,
    );
    final textPainterTitle = TextPainter(
      text: TextSpan(text: "Landmark Coop", style: titleTextStyle),
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: canvasWidth - 2 * padding);
    final double titleX = (canvasWidth - textPainterTitle.width) / 2;
    textPainterTitle.paint(canvas, Offset(titleX, logoY + logoSize + 20));

    // Centered "Transfer Receipt"
    final subtitleTextStyle = TextStyle(
      color: const Color(0xFF000080), // Navy blue
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    final textPainterSubtitle = TextPainter(
      text: TextSpan(text: "Transfer Receipt!", style: subtitleTextStyle),
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: canvasWidth - 2 * padding);
    final double subtitleX = (canvasWidth - textPainterSubtitle.width) / 2;
    textPainterSubtitle.paint(canvas, Offset(subtitleX, logoY + logoSize + 60));

    // Prepare text styles for rows
    final labelTextStyle = TextStyle(
      color: const Color(0xFF000080), // Navy blue
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
    final valueTextStyle = TextStyle(
      color: const Color(0xFF000000), // Black
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    // Divider Paint
    final dividerPaint = Paint()
      ..color = const Color(0xFF000000) // Black divider
      ..strokeWidth = 1;

    // Start Y position for rows
    double currentY = logoY + logoSize + 100;

    // Helper function to draw a row with a divider
    void drawRowWithDivider(
        String label, String value, double width, double padding) {
      // Draw label
      final labelTextPainter = TextPainter(
        text: TextSpan(text: label, style: labelTextStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: canvasWidth / 2 - padding);
      labelTextPainter.paint(canvas, Offset(padding, currentY));

      // Draw value
      final valueTextPainter = TextPainter(
        text: TextSpan(text: value, style: valueTextStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: canvasWidth / 2 - padding);
      valueTextPainter.paint(
          canvas, Offset(canvasWidth - valueTextPainter.width - padding, currentY));

      // Draw horizontal line below the row
      // Calculate the height of the tallest text block (label or value)
      final double textBlockHeight =
      labelTextPainter.height > valueTextPainter.height
          ? labelTextPainter.height
          : valueTextPainter.height;

      // Add padding below the text block and draw the horizontal line
      final double lineY = currentY + textBlockHeight + 10; // Gap of 10

      final double lineStartX = padding;
      final double lineEndX = canvasWidth - padding;
      canvas.drawLine(Offset(lineStartX, lineY), Offset(lineEndX, lineY), dividerPaint);

      // Update currentY for the next row (line gap + vertical gap)
      currentY += rowSpacing + gapBetweenLineAndWidget;
    }

    // Add rows
    drawRowWithDivider("Amount", "NGN ${widget.amount}", canvasWidth, padding);
    drawRowWithDivider("Date", widget.date, canvasWidth, padding);
    drawRowWithDivider("Beneficiary", '${widget.beneficiary} \n ${widget.accountNumber} \n ${widget.bank}', canvasWidth, padding);
    drawRowWithDivider("Sender", widget.fullName, canvasWidth, padding);
    drawRowWithDivider("Status", widget.narration, canvasWidth, padding);
    String disclaimer =  'Landmark Coop has successfully processed this transaction but the completion of the transfers are subject to transaction errors, network interruptions, glitches and other factors that are beyond Landmark Coop\'s control and for which Landmark Coop will not be liable. If any issues are experienced with your transaction, please generate a receipt from the list of recent transactions';

    final disclaimerTextPainter = TextPainter(
      text: TextSpan(text: disclaimer, style: valueTextStyle),
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: (canvasWidth / 1.22) - padding);
    disclaimerTextPainter.paint(canvas, Offset(padding, currentY));

    // Save the canvas content
    final picture = recorder.endRecording();
    final img = await picture.toImage(canvasWidth.toInt(), canvasHeight.toInt());
    final byteData = await img.toByteData(format: ImageByteFormat.png);

    if (byteData != null) {
      final imageBytes = byteData.buffer.asUint8List();
      await Printing.sharePdf(bytes: imageBytes, filename: 'transfer_receipt.jpg');
    }
  }

}