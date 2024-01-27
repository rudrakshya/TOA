import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String image;
  final String label;
  final String link;
  const DashboardCard({
    super.key,
    required this.image,
    required this.label,
    required this.link,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      height: 150,
      padding: const EdgeInsets.all(10),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, link);
        },
        child: Card(
          child: Column(
            children: [
              Image.asset(image, scale: 3.0),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
