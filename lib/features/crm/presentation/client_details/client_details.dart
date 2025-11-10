import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:coopengageplus/core/constants/app_sizes.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/core/constants/text_styles.dart';
import 'package:coopengageplus/features/crm/presentation/client_details/widgets/client_detail_field.dart';
import 'package:coopengageplus/features/crm/presentation/client_details/widgets/client_transaction_chart.dart';
import 'package:coopengageplus/features/crm/presentation/client_details/widgets/recent_activities.dart';
import 'package:coopengageplus/features/crm/presentation/schedule/meetingSchedule.dart';
import 'package:coopengageplus/features/crm/presentation/schedule/taskSchedule.dart';

class ClientDetails extends StatefulWidget {
  const ClientDetails({
    Key? key,
  }) : super(key: key); // Update the constructor

  @override
  _ClientDetailsState createState() => _ClientDetailsState();
}

class _ClientDetailsState extends State<ClientDetails> {
  List<Map<String, String>> clientData = [
    {"Name": "Kebede"},
    {"Phone": "+2519798483"},
    {"Email": "kebede@gmail.com"},
    {"Address": "Bole"},
    {"tinNumber": "03509375"},
    {"accountNumber": "945749875497"},
    {"assignedCRMName": "Chala Tariku"}
  ];
  List<Map<String, dynamic>> data = [
    {
      "type": "Investment",
      "amount": "5,000,000",
      "icon": Icons.arrow_drop_up, // Example of an icon
      "percentage": "+10%",
      "percentageColor": Colors.green, // Color for percentage
    },
    {
      "type": "Withdrwal",
      "amount": "200,000",
      "icon": Icons.arrow_drop_down, // Example of an icon
      "percentage": "-5%",
      "percentageColor": Colors.red, // Color for percentage
    },
    {
      "type": "Savings",
      "amount": "3,000,000",
      "icon": Icons.arrow_drop_down, // Example of an icon
      "percentage": "+15%",
      "percentageColor": Colors.green, // Color for percentage
    },
  ];

  @override
  Widget build(BuildContext context) {
    // double height = MediaQuery.of(context).size.height;
    final client = Get.arguments;
    List<MapEntry<String, dynamic>> extractedData =
        client.toPartialMap().entries.toList();

    print({client});
    return Scaffold(
      backgroundColor: lightBG,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: EdgeInsets.all(Sizes.p10),
          child: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Get.back();
              },
            ),
            backgroundColor: Colors.transparent,
            //   automaticallyImplyLeading: false,
            title: Text(
              "Client Detail",
              style: subHeadingStyle,
            ),
          ),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(Sizes.p16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      offset: Offset(-4, -4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.grey.shade200,
                      offset: Offset(4, 4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    gapH16,
                    Center(
                      child: CircleAvatar(
                        radius: Sizes.p48,
                        child: Icon(
                          Icons.person,
                          color: primaryBlue,
                          size: Sizes.p32,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: extractedData.length,
                      itemBuilder: (context, index) {
                        String label = extractedData[index].key;
                        String value = extractedData[index].value.toString();
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: Sizes.p10, horizontal: Sizes.p12),
                          child: ClientDetailField(label: label, value: value),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.all(Sizes.p16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade100,
                        offset: Offset(-4, -4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.grey.shade200,
                        offset: Offset(4, 4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(children: [
                    Padding(
                        padding: EdgeInsets.all(Sizes.p10),
                        child: Text(
                          "Transaction Analysis",
                          style: sectionTitleStyle,
                        )),
                    gapH12,
                    BarChartSample3(),
                    gapH10
                  ]),
                )),
            gapH12,
            Padding(
                padding: EdgeInsets.symmetric(horizontal: Sizes.p16),
                child: Text(
                  "Recent Activities",
                  style: sectionTitleStyle,
                )),
            gapH10,
            ListView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  // Destructure the data
                  String type = data[index]["type"];
                  String amount = data[index]["amount"];
                  String percentage = data[index]["percentage"];
                  var icon = data[index]["icon"];
                  var percentageColor = data[index]["percentageColor"];

                  // Return the RecentActivities widget with destructured data
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Sizes.p16, vertical: Sizes.p4),
                    child: RecentActivities(
                      type: type,
                      amount: amount,
                      percentage: percentage,
                      icon: icon,
                      pecentageColor: percentageColor,
                    ),
                  );
                }),
            gapH32
          ],
        ),
      )),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.blue,
        icon: Icons.add,
        activeIcon: Icons.close,
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            shape: StadiumBorder(),
            backgroundColor: const Color.fromARGB(255, 49, 114, 167),
            child: Icon(Icons.task, color: Colors.white),
            label: "New Task",
            onTap: () {
              Get.to(() => Taskschedule(), arguments: client.id);
            },
          ),
          SpeedDialChild(
            backgroundColor: Color.fromARGB(255, 75, 17, 137),
            shape: StadiumBorder(),
            child: const Icon(Icons.people, color: Colors.white),
            label: "Schedule Meeting",
            onTap: () {
              Get.to(() => MeetingSchedule(), arguments: client.id);
            },
          ),
        ],
      ),
    );
  }
}
