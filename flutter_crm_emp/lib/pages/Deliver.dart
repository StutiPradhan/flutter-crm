import 'package:flutter_crm_emp/pages/Deliverable.dart';
import 'package:fl_query/fl_query.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Deliver());
}

class Deliver extends StatefulWidget {
  const Deliver({super.key});

  @override
  State<Deliver> createState() => _DeliverState();
}

class _DeliverState extends State<Deliver> {
  @override
  Widget build(BuildContext context) {
    final queryClient = QueryClient.of(context);
    final threadListQuery = queryClient.getQuery('thread_list');
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            centerTitle: true,
            title: const Text(
              'Deliverables',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            actions: threadListQuery?.isRefreshing ?? false ? [const Text("Fetching...")] : [],
          ),
          body: const Deliverables(),
        ));
  }
}
