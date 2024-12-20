import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:coopengageplus/features/onboarding/marchent/presentation/widget/printable_data.dart';
import 'package:printing/printing.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// class SaveBtnBuilder extends StatelessWidget {
//   const SaveBtnBuilder({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         foregroundColor: Colors.indigo,
//         backgroundColor: Colors.blue,
//         minimumSize: const Size(double.infinity, 45),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//       ),
//       onPressed: () => printDoc(),
//       child: const Text(
//         "Save as PDF",
//         style: TextStyle(color: Colors.white, fontSize: 20.00),
//       ),
//     );
//   }

//   Future<void> printDoc() async {
//     final image = await imageFromAssetBundle(
//       "assets/logo.png",
//     );
//     final doc = pw.Document();
//     doc.addPage(pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return buildPrintableData(image);
//           // return
//         }));
//     await Printing.layoutPdf(
//         onLayout: (PdfPageFormat format) async => doc.save());
//   }
// }

class SaveBtnBuilder extends StatelessWidget {
  final Uint8List imageBytes; // Image bytes to pass to the child
  final Map<String, dynamic> data; // Registration data

  const SaveBtnBuilder({
    Key? key,
    required this.imageBytes,
    required this.data,
    required Uint8List image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.indigo,
        backgroundColor: Colors.blue,
        minimumSize: const Size(double.infinity, 45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () => printDoc(context),
      child: const Text(
        "Save as PDF",
        style: TextStyle(color: Colors.white, fontSize: 20.00),
      ),
    );
  }

  Future<void> printDoc(BuildContext context) async {
    // If you want to use the imageBytes, you can use `pw.MemoryImage` for the PDF generation
    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return buildPrintableData(imageBytes, data);
      },
    ));
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }

  // This method is for building the printable data from imageBytes and data
  pw.Widget buildPrintableData(
      Uint8List imageBytes, Map<String, dynamic> data) {
    return pw.Column(
      children: [
        pw.Image(pw.MemoryImage(imageBytes)), // Add the image from bytes
        pw.Text(
            "Merchant Data: ${data['Marchent Name']}"), // Example usage of registration data
        // You can add more data from `data` if needed, e.g., pw.Text("City: ${data['merchantCity']}")
      ],
    );
  }
}
