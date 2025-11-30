import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/data/repositories/firebase_auth_repository.dart';
import '../../../auth/data/models/user_model.dart';

class EmployeesPage extends ConsumerWidget {
  const EmployeesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).value;

    if (userProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Employees')),
      body: Column(
        children: [
          // Shop ID Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            width: double.infinity,
            child: Column(
              children: [
                const Text('Your Shop ID', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SelectableText(
                  userProfile.shopId,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Share this ID with employees so they can join your shop during signup.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Employee List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('shop_id', isEqualTo: userProfile.shopId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No employees found.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final employee = UserModel.fromMap(data);
                    final isMe = employee.uid == userProfile.uid;

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(employee.email[0].toUpperCase()),
                      ),
                      title: Text(employee.email),
                      subtitle: Text(employee.role.toUpperCase()),
                      trailing: isMe ? const Chip(label: Text('YOU')) : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
