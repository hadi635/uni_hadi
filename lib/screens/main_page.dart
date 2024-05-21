// mainpage.dart
import 'package:flutter/material.dart';
import 'package:overlapping_panels/overlapping_panels.dart';
import 'package:overlapping_panels_demo/screens/chat_screen.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:overlapping_panels_demo/screens/left_page.dart';
import 'package:overlapping_panels_demo/widgets/footer_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Offset footerOffset = const Offset(0, 1);
  final GlobalKey<SliderDrawerState> _key = GlobalKey<SliderDrawerState>();
  String selectedChannel = 'Chats';
  String selectedUniversity = 'LAU';

  void _onChannelSelected(String university, String channel) {
    setState(() {
      selectedUniversity = university;
      selectedChannel = channel;
    });
    _key.currentState!.closeSlider();
    footerOffset = const Offset(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SliderDrawer(
            sliderBoxShadow:
                SliderBoxShadow(color: Colors.blue, blurRadius: 36),
            key: _key,
            sliderOpenSize: 329,
            appBar: SliderAppBar(
              drawerIcon: IconButton(
                onPressed: () {
                  setState(() {
                    if (_key.currentState!.isDrawerOpen == false) {
                      _key.currentState!.openSlider();
                      footerOffset = const Offset(0, 0);
                    } else if (_key.currentState!.isDrawerOpen == true) {
                      _key.currentState!.closeSlider();
                      footerOffset = const Offset(0, 1);
                    }
                  });
                },
                icon: const Icon(Icons.menu),
              ),
              appBarColor: Colors.blue,
              title: Text('$selectedUniversity - $selectedChannel',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700)),
            ),
            slider: Builder(builder: (context) {
              return LeftPage(
                onChannelSelected: (p0, p1) {
                  setState(() {
                    _onChannelSelected(p0, p1);
                  });
                },
              );
            }),
            child: Builder(
              builder: (context) {
                return ChatScreen(
                    university: selectedUniversity, channel: selectedChannel);
              },
            ),
          ),
          FooterWidget(footerOffset: footerOffset)
        ],
      ),
    );
  }
}
