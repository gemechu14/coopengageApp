import 'package:flutter/material.dart';
import 'package:coopengageplus/features/crm/presentation/dashboard/widgets/priority_client_card.dart';

class PriorityClient extends StatelessWidget {
  const PriorityClient({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> data = [
      {
        "imgUrl": "https://example.com/image1.jpg",
        "name": "Samuel Daniel",
        "reason": "Last contact with customer",
        "priority": "High"
      },
      {
        "imgUrl": "https://example.com/image2.jpg",
        "name": "Kebede Balcha",
        "reason": "High transaction volume this month",
        "priority": "Medium"
      },
      {
        "imgUrl": "https://example.com/image3.jpg",
        "name": "Miratuu Solomon",
        "reason": "Critical system update required",
        "priority": "High"
      },
      {
        "imgUrl": "https://example.com/image4.jpg",
        "name": "Dammee Wakjiraa",
        "reason": "Follow-up on unresolved issue",
        "priority": "Low"
      },
      {
        "imgUrl": "https://example.com/image5.jpg",
        "name": "Carraa Abdii",
        "reason": "Security vulnerability detected",
        "priority": "High"
      }
    ];
    return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            return PriorityClientCard(content: data[index]);
          },
        ));
  }
}
// SizedBox(
//       height: 200,
//       child: highProfileClients.when(
//         data: (clients) {
//           // Ensure 'clients' is not null or empty
//           if (clients != null && clients.isNotEmpty) {
//             return ListView.builder(
//               scrollDirection: Axis.horizontal,
//               shrinkWrap: true,
//               physics: BouncingScrollPhysics(),
//               itemCount:
//                   clients.length, // Use 'clients.length' to get the item count
//               itemBuilder: (context, index) {
//                 // Access individual client object
//                 final client = clients[index];
//                 print({client});
//                 return PriorityClientCard(
//                     content: client); // Pass the client to the card widget
//               },
//             );
//           } else {
//             return Center(
//                 child: Text(
//                     'No clients available')); // Show when there are no clients
//           }
//         },
//         loading: () => Center(
//             child:
//                 CircularProgressIndicator()), // Show loading spinner while data is fetching
//         error: (err, stack) =>
//             Center(child: Text("Error: $err")), // Handle error state
//       ),
//     );
