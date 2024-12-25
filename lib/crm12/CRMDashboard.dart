// ignore_for_file: sized_box_for_whitespace, unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:coopengageplus/crm12/ListOfCustomers.dart';
import 'package:pie_chart/pie_chart.dart';

class CRMDashboard extends StatefulWidget {
  const CRMDashboard({super.key});

  @override
  State<CRMDashboard> createState() => _CRMDashboardState();
}

class _CRMDashboardState extends State<CRMDashboard> {
  // Data and colors for the chart
  Map<String, double> dataMap = {
    "Small Business": 10,
    "Medium Business": 2,
    "Large Business": 19,
  };

  // Define colors for each business type
  final colorList = <Color>[
    Colors.green, // Small Business
    Colors.red, // Medium Business
    Colors.blue, // Large Business
  ];
  final List<Map<String, dynamic>> tasks = [
    {
      "title": "Meeting with John on the next investment",
      "icon": Icons.check_circle
    },
    {
      "title":
          "Review project deadlines with the teamuytdfghjklkjhgfghjkl;lkjhchkl;kjhg",
      "icon": Icons.access_time
    },
    {"title": "Prepare presentation for the client", "icon": Icons.warning},
    {"title": "Discuss quarterly results with management", "icon": Icons.error},
    {
      "title": "Schedule follow-up meeting with stakeholders",
      "icon": Icons.event
    },
  ];
  bool _showAllTasks = false;
  // Total value
  // double totalValue = dataMap.values.reduce((a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    double totalValue = dataMap.values.reduce((a, b) => a + b);
    // Show only the first 3 tasks in the list
    final displayedTasks = tasks.take(3).toList();
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
              fontSize: 31, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        actions: const [Icon(Icons.notifications)],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Container(
              width: width < 600 ? double.infinity : width * 0.7,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 15),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Listofcustomers(),
                            ),
                            (route) => false);
                      },
                      child: Card(
                        color: Colors.white,
                        // shape: context
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Customer Segmentation",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 25,
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Pie Chart
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      PieChart(
                                        dataMap: dataMap,
                                        colorList: colorList,
                                        chartRadius:
                                            MediaQuery.of(context).size.width *
                                                0.20,
                                        chartType: ChartType.ring,
                                        ringStrokeWidth: 5,
                                        legendOptions: const LegendOptions(
                                            showLegends: false),
                                        chartValuesOptions:
                                            const ChartValuesOptions(
                                                showChartValues: false),
                                      ),
                                      // Centered Text
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Total',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            totalValue.toStringAsFixed(
                                                0), // Display total value as integer
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // Legend
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: dataMap.keys.map((key) {
                                      int index =
                                          dataMap.keys.toList().indexOf(key);
                                      Color color = colorList[index];

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Row(
                                          children: [
                                            // Column for color indicator and business type name
                                            Row(
                                              children: [
                                                Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    color: color,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  key,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: dataMap.keys.map((key) {
                                      int index =
                                          dataMap.keys.toList().indexOf(key);
                                      double value = dataMap[key]!;

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Row(
                                          children: [
                                            // Column for color indicator and business type name

                                            // Column for value
                                            Text(
                                              value.toStringAsFixed(0),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign
                                                  .end, // Align value to the right
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header text
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Here are your tasks for Today:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showAllTasks =
                                        !_showAllTasks; // Toggle the state
                                  });
                                },
                                child: Text(
                                  _showAllTasks ? 'Show less' : 'See all',
                                  style: const TextStyle(
                                      color: Colors.blue, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Task list
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayedTasks.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 4.0,
                                    spreadRadius: 2.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Icon(displayedTasks[index]["icon"],
                                    color: Colors.blue),
                                title: Text(
                                  displayedTasks[index]["title"],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
