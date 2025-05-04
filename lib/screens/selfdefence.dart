import 'package:flutter/material.dart';
import 'package:test_rait_new/Screens/homePage.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'fake_call.dart';
import 'guide_main.dart';

class SelfDefencePage extends StatelessWidget {
  final List<Map<String, String>> accordionData = [
    {"title": "Basic Self Defence", "videoUrl": "KVpxP3ZZtAc"},
    {"title": "Advanced Techniques", "videoUrl": "q1pBBRi3XF8"},
    {"title": "Safety Tips for Women", "videoUrl": "lEPLBFzneio"},
    {"title": "Self Defence Tools", "videoUrl": "7QkMQfpaZPc"},
  ];

  final String academyLocationUrl = "https://maps.app.goo.gl/BjWuWv7yRgtfW1zf7";
  final String wsdcWebsiteUrl = "https://www.womenssdc.com"; // Replace with actual WSDC website URL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Self Defence"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...accordionData.map((data) => SelfDefenceAccordion(
              title: data['title']!,
              videoUrl: data['videoUrl']!,
            )),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () async {
                  if (await canLaunchUrl(Uri.parse(wsdcWebsiteUrl))) {
                    launchUrl(Uri.parse(wsdcWebsiteUrl), mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open the WSDC website')),
                    );
                  }
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/wsdc_logo.png', // Add your logo image to the assets/images directory
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Women's Self Defense Center - WSDC",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            "Women's Self Defense Center - WSDC, is an initiative of Shri Aaditya Thackeray & Shihan Akshay Kumar. The center imparts self-defense training to women of any age free of cost.",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  backgroundColor: Colors.blue,
                ),
                onPressed: () async {
                  if (await canLaunchUrl(Uri.parse(academyLocationUrl))) {
                    launchUrl(Uri.parse(academyLocationUrl), mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open Google Maps')),
                    );
                  }
                },
                child: const Text(
                  "View Self Defence Academy Location",
                  style: TextStyle(fontSize: 16,color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

    );
  }
}

class SelfDefenceAccordion extends StatefulWidget {
  final String title;
  final String videoUrl;

  const SelfDefenceAccordion({Key? key, required this.title, required this.videoUrl})
      : super(key: key);

  @override
  State<SelfDefenceAccordion> createState() => _SelfDefenceAccordionState();
}

class _SelfDefenceAccordionState extends State<SelfDefenceAccordion> {
  bool _isOpen = false;
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoUrl,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ExpansionTile(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            _isOpen = expanded;
          });
        },
        children: [
          if (_isOpen)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
              ),
            ),
        ],
      ),
    );
  }
}
