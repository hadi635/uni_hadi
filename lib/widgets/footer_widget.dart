import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:overlapping_panels_demo/screens/profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class FooterWidget extends StatefulWidget {
  final Offset footerOffset;

  const FooterWidget({Key? key, required this.footerOffset}) : super(key: key);

  @override
  _FooterWidgetState createState() => _FooterWidgetState();
}

class _FooterWidgetState extends State<FooterWidget> {
  final StreamController<Map<String, dynamic>> _userDataController =
      StreamController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String userId = '';
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        userId = prefs.getString('userId')!;
      });
      final response = await http
          .get(Uri.parse('http://192.168.1.117:4000/get_user/$userId'));
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        _userDataController.add(userData);
      } else {
        throw Exception('Failed to load user data');
      }
        } catch (error) {
      _userDataController.addError(error);
    }
  }

  @override
  void dispose() {
    _userDataController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 160),
        offset: widget.footerOffset,
        child: SizedBox(
          height: 90,
          child: Material(
            color: Colors.blue,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      _loadUserData();
                    },
                    icon: const Icon(
                      Icons.public,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.person_pin,
                      color: Colors.white54,
                      size: 32,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: StreamBuilder<Map<String, dynamic>>(
                      stream: _userDataController.stream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Icon(Icons.error, color: Colors.red);
                        } else if (snapshot.hasData) {
                          final userData = snapshot.data!;
                          if (userData['success']) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileEditScreen(
                                      userId: userId,
                                      initialUsername: userData['user']
                                          ['username'],
                                      initialImageUrl: userData['user']
                                          ['imageUrl'],
                                    ),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                radius: 16,
                                foregroundImage:
                                    NetworkImage(userData['user']['imageUrl']),
                              ),
                            );
                          } else {
                            return const Icon(Icons.person,
                                color: Colors.white54, size: 32);
                          }
                        } else {
                          return const Icon(Icons.person,
                              color: Colors.white54, size: 32);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      alignment: Alignment.bottomCenter,
    );
  }
}
