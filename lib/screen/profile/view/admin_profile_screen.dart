// import 'package:ammentor/components/theme.dart';
// import 'package:ammentor/screen/auth/provider/auth_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class AdminProfileScreen extends ConsumerWidget{
//   const AdminProfileScreen({super.key})

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final email = ref.watch(userEmailProvider);

//     if (email == null) {
//       return const Center(child: Text("Email not found. Please login."));
//     }

//     // Hardcoding for testing purpose, to be removed later on
//     final mentees = [
//       {
//         'name': 'Mentee 1',
//         'tags': ['Web', 'Mobile'],
//         'task': 'TASK-09',
//         'progress': 95,
//         'projects': ['amMentor', 'CIR'],
//       },
//       {
//         'name': 'Mentee 2',
//         'tags': ['Web', 'Mobile'],
//         'task': 'TASK-09',
//         'progress': 95,
//         'projects': ['amMentor', 'CIR'],
//       },
//     ];

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         title: const Text(
//           "Profile",
//           style: TextStyle(
//             color: AppColors.white,
//             fontWeight: FontWeight.bold
//           ),
//         ),
//         leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
//       ),
//       body: Padding(
//         padding:
//         ),
//     );
//   }
// }