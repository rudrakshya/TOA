import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:toa/modules/Dashboard/components/dahboard_card.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String appBarHeader = "Federation of Malda TOA";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              "assets/images/logo.png",
              scale: 8.0,
            ),
            const SizedBox(width: 10),
            AutoSizeText(
              appBarHeader,
              minFontSize: 12,
              maxFontSize: 18,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: const Column(
        children: [
          Row(
            children: [
              DashboardCard(
                image: "assets/icons/truck_blue.png",
                label: "Register vehicle",
                link: "/vehicle",
              ),
              DashboardCard(
                image: "assets/icons/qr_scanner.png",
                label: "Scan QR code",
                link: "/",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
