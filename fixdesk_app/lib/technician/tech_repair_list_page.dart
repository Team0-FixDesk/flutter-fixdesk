import 'package:flutter/material.dart';
import '../service/api_service.dart';
import 'tech_detail_repair.dart';

class TechRepairListPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const TechRepairListPage({super.key, required this.userData});

  @override
  State<TechRepairListPage> createState() => _TechRepairListPageState();
}

class _TechRepairListPageState extends State<TechRepairListPage> {
  List repairs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRepairs();
  }

  Future<void> loadRepairs() async {
    final data = await ApiService.getAllRepairs();

    if (!mounted) return;

    setState(() {
      repairs = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        /// HEADER
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "รายการงานซ่อม",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        /// LIST
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: repairs.length,
                  itemBuilder: (context, index) {

                    final repair = repairs[index];

                    return ListTile(
                      title: Text(repair['rf_problem'] ?? '-'),
                      subtitle: Text("#${repair['rf_code']}"),
                      trailing: const Icon(Icons.arrow_forward_ios),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TechDetailRepairPage(repair: repair),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}