// leftpage.dart
import 'package:flutter/material.dart';
import 'package:overlapping_panels_demo/utils/data.dart';

class LeftPage extends StatefulWidget {
  final Function(String, String) onChannelSelected;

  const LeftPage({Key? key, required this.onChannelSelected}) : super(key: key);

  @override
  State<LeftPage> createState() => _LeftPageState();
}

class _LeftPageState extends State<LeftPage> {
  List<String> universityNames = ["AUB", "LIU", "LU", "LAU", "IULL", "USJ"];
  final universityImages = [
    "https://www.aub.edu.lb/PublishingImages/spotlight/Office_of_The_President_thumb.png",
    "https://upload.wikimedia.org/wikipedia/ar/archive/4/4b/20170617001001%21LIU_Logo.png",
    "https://www.demos-project.eu/images/2021/07/28/partner3.png",
    "https://i.pinimg.com/originals/18/8e/5e/188e5e0b31f829b9a8ca026fdd902836.png",
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaZLEDCHF0zvfHtHChYMctOhbqZCzvSKPIgyrqZOc98A&s',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQksB9XiyHdZzKOnbKQjPp9a0dLZObqzNH87x8m0P5F-A&s',
  ];
  String uni = 'AUB';
  bool _isUniversitySelected = false;
  int indexs = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 32, 32, 32),
        child: Row(
          children: [
            SizedBox(
              width: 67,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: ListView.builder(
                  itemCount: universityNames.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 4),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  indexs = index;
                                  uni = universityNames[index];
                                  _isUniversitySelected = true;
                                });
                                // Optionally, you can call the callback with a default channel
                                // widget.onChannelSelected(uni, 'default');
                              },
                              child: Image.network(
                                universityImages[index],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey[100]!))),
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 16),
                          child: Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3, vertical: 4),
                                  child: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.white,
                                    child: ClipOval(
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              indexs = indexs;
                                              uni = universityNames[indexs];
                                              _isUniversitySelected = true;
                                            });
                                            // Optionally, you can call the callback with a default channel
                                            // widget.onChannelSelected(uni, 'default');
                                          },
                                          child: Image.network(
                                            universityImages[indexs],
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  uni,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ],
                            ),
                          )),
                      Expanded(
                        child: Material(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          child: _isUniversitySelected
                              ? ListView(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(
                                          top: 16, left: 16, right: 0),
                                      child: Text(
                                        'TEXT CHANNELS',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.grey),
                                      ),
                                    ),
                                    ...[
                                      "Rules",
                                      "Chats",
                                      "Books",
                                      "Tools",
                                      "Tutorials/Pdfs",
                                      "Events",
                                      'Job/InternShips'
                                    ].map((channel) => ListTile(
                                          leading: const Icon(Icons.tag),
                                          horizontalTitleGap: 0,
                                          title: Text(channel),
                                          onTap: () {
                                            if (channel == "Rules") {
                                              showModalBottomSheet(
                                                context: context,
                                                backgroundColor: Colors.black87,
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          top: Radius.circular(
                                                              25.0)),
                                                ),
                                                builder:
                                                    (BuildContext context) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Center(
                                                          child: Container(
                                                            width: 50,
                                                            height: 5,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .grey[700],
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        const Text(
                                                          'Channel Rules',
                                                          style: TextStyle(
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 20),
                                                        const Text(
                                                          '1. No bad words.',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white70),
                                                        ),
                                                        const Text(
                                                          '2. No spam messages.',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white70),
                                                        ),
                                                        const Text(
                                                          '3. Respect others.',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white70),
                                                        ),
                                                        const Text(
                                                          '4. No sharing personal information.',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white70),
                                                        ),
                                                        const Text(
                                                          '5. Follow community guidelines.',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white70),
                                                        ),
                                                        // Add more rules here
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            } else {
                                              widget.onChannelSelected(
                                                  uni, channel);
                                            }
                                          },
                                        )),
                                  ],
                                )
                              : const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'Select a University',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: 50,
            )
          ],
        ),
      ),
    );
  }
}
