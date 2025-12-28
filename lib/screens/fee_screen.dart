import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/fee.dart';

class FeeScreen extends StatefulWidget {
  final int studentId;

  const FeeScreen({super.key, required this.studentId});

  @override
  State<FeeScreen> createState() => _FeeScreenState();
}

class _FeeScreenState extends State<FeeScreen> {
  List<Fee> fees = [];

  @override
  void initState() {
    super.initState();
    loadFees();
  }

  Future<void> loadFees() async {
    final data =
    await DatabaseHelper.instance.getFeesByStudent(widget.studentId);
    setState(() => fees = data);
  }

  Future<void> addDummyFee() async {
    final fee = Fee(
      studentId: widget.studentId,
      amount: 2500,
      dueDate: '25-03-2025',
      status: 'Pending',
    );

    await DatabaseHelper.instance.insertFee(fee);
    loadFees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Fees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addDummyFee,
          )
        ],
      ),
      body: fees.isEmpty
          ? const Center(child: Text('No fee records'))
          : ListView.builder(
        itemCount: fees.length,
        itemBuilder: (context, index) {
          final f = fees[index];
          return Card(
            child: ListTile(
              title: Text('৳ ${f.amount}'),
              subtitle: Text(
                'Due: ${f.dueDate} | Status: ${f.status}',
              ),
            ),
          );
        },
      ),
    );
  }
}
