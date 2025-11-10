import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/features/home/main_page.dart';
import 'package:flutter/material.dart';

class DialogHelper {
  // Static method to show an error dialog
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Rounded corners
          ),
          backgroundColor: Colors.red[50], // Light red background
          title: Text(
            "Error",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.red[800], // Darker red for title
            ),
          ),
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[800], // Error icon color
                size: 32.0,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.red[800], // Button background color
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            // Intercept back button press and navigate to MainPage
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainPage()),
              (route) => false, // Remove all the previous routes
            );
            return Future.value(false); // Prevent the default pop action
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0), // Rounded corners
            ),
            backgroundColor: Colors.green[50], // Light green background
            title: Text(
              "Success",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: cyanblueColor, // Dark green for title
              ),
            ),
            content: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: cyanblueColor, // Success icon color
                  size: 32.0,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Close the dialog and navigate to MainPage
                  Navigator.of(context).pop(); // Close the dialog

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                    (route) => false, // Remove all the previous routes
                  );
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: cyanblueColor, // Button background color
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
