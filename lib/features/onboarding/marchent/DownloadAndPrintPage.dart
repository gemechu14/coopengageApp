// import 'package:flutter/material.dart';
// import 'package:printing/printing.dart'; // For printing functionality
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:flutter/services.dart'; // For downloading functionality
// import 'package:http/http.dart' as http;
// import 'dart:typed_data';

// class DownloadAndPrintPage extends StatelessWidget {
//   final String firstName = "John";
//   final String email = "john.doe@example.com";
//   final String imageUrl = "assets/cart.png"; // Image URL

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Download and Print Page"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // User Info
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("First Name: $firstName", style: TextStyle(fontSize: 18)),
//                 SizedBox(height: 8),
//                 Text("Email: $email", style: TextStyle(fontSize: 18)),
//               ],
//             ),
//             SizedBox(height: 20),

//             // Image display
//             // Image.network(imageUrl),

//             SizedBox(height: 20),

//             // Download button
//             ElevatedButton(
//               onPressed: () async {
//                 // Generate the PDF
//                 final pdfData = await _generatePdf();

//                 // Trigger the download
//                 await Printing.sharePdf(
//                     bytes: pdfData, filename: 'user_info.pdf');
//               },
//               child: Text("Download PDF"),
//             ),

//             SizedBox(height: 16),

//             // Print button
//             ElevatedButton(
//               onPressed: () async {
//                 // Generate the PDF
//                 final pdfData = await _generatePdf();

//                 // Send the generated PDF to the printer
//                 await Printing.layoutPdf(
//                   onLayout: (PdfPageFormat format) async {
//                     return pdfData; // Use the PDF data to print
//                   },
//                 );
//               },
//               child: Text("Print Page"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Generate the PDF containing the user's name, email, and image
//   Future<Uint8List> _generatePdf() async {
//     final pdf = pw.Document();

//     // final imageResponse =
//     //     await http.get(Uri.parse(imageUrl)); // Fetch the image
//     // final imageProvider =
//     //     pw.MemoryImage(imageResponse.bodyBytes); // Convert image to pdf format

//     // Add content to the PDF
//     pdf.addPage(pw.Page(
//       build: (pw.Context context) {
//         return pw.Column(
//           children: [
//             pw.Text('First Name: $firstName',
//                 style: pw.TextStyle(fontSize: 20)),
//             pw.Text('Email: $email', style: pw.TextStyle(fontSize: 20)),
//             pw.SizedBox(height: 20),
//             // pw.Image(imageProvider), // Add the image to the PDF
//           ],
//         );
//       },
//     ));

//     // Return the generated PDF
//     return pdf.save();
//   }
// }

import 'dart:typed_data';

import 'package:coopengageplus/features/onboarding/marchent/presentation/component/MerchantDetailsBuilder.dart';
import 'package:coopengageplus/features/onboarding/marchent/presentation/widget/save_btn.dart';
import 'package:flutter/material.dart';


class DownloadAndPrintPage extends StatefulWidget {
  final Map<String, dynamic> registrationData;
  final Uint8List imageBytes;

  const DownloadAndPrintPage(
      {Key? key,
      required this.registrationData,
      required this.title,
      required this.imageBytes})
      : super(key: key);

  final String title;

  @override
  State<DownloadAndPrintPage> createState() =>
      _MyHomePageState(registrationData, imageBytes);
}

class _MyHomePageState extends State<DownloadAndPrintPage> {
  final Map<String, dynamic> registrationData;
  final Uint8List imageBytes;

  _MyHomePageState(this.registrationData, this.imageBytes);

  @override
  Widget build(BuildContext context) {
    final registrationData1 = {
      'Marchent Name': registrationData['marchentName'].toString(),
      // 'Phone Number': registrationData['phoneNumber'].toString(),
      // 'Business Type': registrationData['businessType'].toString(),
      // 'businessName': registrationData['businessName'].toString(),
      // 'Address': registrationData['marchentAddress'].toString(),
    };
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(25.00),
            child: Column(
              children: [
                Center(
                    child: Image.memory(
                  imageBytes,
                  height: 200,
                  width: 400,
                )),
                // Align(
                //   alignment: Alignment.topCenter,
                //   child: ImageBuilder(
                //     imagePath: registrationData['qrcode'],
                //     imgWidth: 250,
                //     imgheight: 250,
                //   ),
                // ),
                MerchantDetailsBuilder(registrationData: registrationData1),
                // InvoiceBuilder(),
                // // HeightSpacer(myHeight: 15.00),
                // Text(
                //   "Thanks for choosing our service!",
                //   style: TextStyle(color: Colors.grey, fontSize: 15.00),
                // ),
                // // HeightSpacer(myHeight: 5.00),
                // Text(
                //   "Contact the branch for any clarifications.",
                //   style: TextStyle(color: Colors.grey, fontSize: 15.00),
                // ),
                // // HeightSpacer(myHeight: 15.00),

                const SizedBox(
                  height: 60,
                ),
                // SaveBtnBuilder(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: SaveBtnBuilder(
          image: imageBytes,
          data: registrationData1,
          imageBytes: imageBytes,
        ),
        height: 70,
      ),
    );
  }
}
