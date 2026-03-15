import 'package:flutter/material.dart';
import '../technician/tech_home_page.dart';
import '../technician/tech_repair_list_page.dart';
import '../technician/tech_my_profile.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      color: Colors.white,
      child: Row(
        children: [

          /// LOGO
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.build,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          /// TEXT FIXDESK
          Text(
            "FixDesk",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
