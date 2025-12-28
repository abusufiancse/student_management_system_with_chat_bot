// import 'package:flutter/material.dart';
//
// import '../../db/database_helper.dart';
// import '../parents/parent_dashboard.dart';
//
// class ParentAccessScreen extends StatefulWidget {
//   final String initialRoll;
//   const ParentAccessScreen({super.key, required this.initialRoll});
//
//   @override
//   State<ParentAccessScreen> createState() => _ParentAccessScreenState();
// }
//
// class _ParentAccessScreenState extends State<ParentAccessScreen> {
//   final rollCtrl = TextEditingController();
//
//   void check() async {
//     final student = await DatabaseHelper.instance
//         .getApprovedStudentByRoll(rollCtrl.text.trim());
//
//     if (student == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Invalid or not approved roll number')),
//       );
//       return;
//     }
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ParentDashboard(student: student, role: 'parent',),
//       ),
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     rollCtrl.text = widget.initialRoll;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Parent Access')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: rollCtrl,
//               decoration:
//               const InputDecoration(labelText: 'Enter Student Roll Number'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(onPressed: check, child: const Text('View Details')),
//           ],
//         ),
//       ),
//     );
//   }
// }
