import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'emergencycontacts.dart';
import 'fake_call.dart';
import 'generalsafety.dart';
import 'kawachBot.dart';
import 'selfdefence.dart';

class GuidePage extends StatelessWidget {
  GuidePage({super.key});

  // Sample data for the heatmap (fake data points for danger-prone areas)
  final List<WeightedLatLng> dangerLocations = [
    WeightedLatLng(LatLng(19.0760, 72.8777), 1.0),  // Mumbai central
    WeightedLatLng(LatLng(19.1050, 72.8347), 0.8),  // Bandra
    WeightedLatLng(LatLng(19.0760, 72.9125), 0.9),  // Andheri
    WeightedLatLng(LatLng(19.0445, 72.8517), 0.7),  // Malad
    WeightedLatLng(LatLng(19.2183, 72.9780), 0.6),  // Navi Mumbai
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map widget
            SizedBox(
              height: 250,
              child: FlutterMap(
                options: const MapOptions(),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  HeatMapLayer(
                    heatMapDataSource: InMemoryHeatMapDataSource(
                      data: dangerLocations,
                    ),
                    heatMapOptions: HeatMapOptions(
                      gradient: {
                        0.25: MaterialColor(0xFF4CAF50, const <int, Color>{
                          500: Colors.green,
                        }),
                        0.5: MaterialColor(0xFFFFEB3B, const <int, Color>{
                          500: Colors.yellow,
                        }),
                        0.75: MaterialColor(0xFFFF9800, const <int, Color>{
                          500: Colors.orange,
                        }),
                        1.0: MaterialColor(0xFFF44336, const <int, Color>{
                          500: Colors.red,
                        }),
                      },
                      radius: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Legend
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem('High', Colors.red),
                  _buildLegendItem('Medium', Colors.orange),
                  _buildLegendItem('Low', Colors.yellow),
                  _buildLegendItem('Least', Colors.green),
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTab(context, 'General Safety Tips', 'assets/general_safety.png', navigateTo: SafetyChecklistPage()),
                  _buildTab(context, 'Learn Self Defence', 'assets/self_defence.png', navigateTo: SelfDefencePage()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTab(context, 'Emergency Contacts', 'assets/emergency_contact.png', navigateTo: Econtactpage()),
                  _buildTab(context, 'Talk with Kawach Bot', 'assets/bot.png', navigateTo: SafetySupport()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTab(BuildContext context, String title, String imagePath, {Widget? navigateTo}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (navigateTo != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => navigateTo),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Image.asset(
                imagePath,
                height: 80,
                width: 80,
              ),
              const SizedBox(height: 8.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}