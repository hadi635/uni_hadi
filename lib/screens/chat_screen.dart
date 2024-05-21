// ignore_for_file: library_prefixes, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final String university;
  final String channel;

  const ChatScreen({required this.university, required this.channel, Key? key})
      : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = true;
  String _error = '';
  IO.Socket? _socket;
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _loadUserData();
    _connectSocket();
    fetchMessages();
  }

  void _connectSocket() {
    _socket = IO.io('http://192.168.1.117:4000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket?.connect();
    _socket?.on('connect', (_) {
      _socket?.on('output', (data) {
        final List<dynamic> messageJson = data;
        setState(() {
          _messages = messageJson
              .map((json) => Message.fromJson(json))
              .where((message) => message.university == widget.university)
              .toList();
        });
      });
    });
    _socket?.on('disconnect', (_) => print('Disconnected from websocket'));
  }

  @override
  void didUpdateWidget(ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.channel != widget.channel ||
        oldWidget.university != widget.university) {
      fetchMessages();
    }
  }

  Future<void> fetchMessages() async {
    final url = 'http://192.168.1.117:4000/messages?channel=${widget.channel}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> messageJson = json.decode(response.body);
        List<Message> messages = messageJson
            .map((json) => Message.fromJson(json))
            .where((message) => message.university == widget.university)
            .toList();

        for (var message in messages) {
          if (message.user.isNotEmpty) {
            final userDataResponse = await http.get(Uri.parse(
                'http://192.168.1.117:4000/get_user/${message.user}'));

            if (userDataResponse.statusCode == 200) {
              final userData = json.decode(userDataResponse.body);
              message.username = userData['user']['username'];
              message.imageUrl = userData['user']['imageUrl'];
            }
          }
        }

        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          _error = 'Failed to load messages';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load messages: $e';
        _isLoading = false;
      });
    }
  }

  String userId = '';
  String username = '';
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        userId = prefs.getString('userId')!;
      });

      if (userId.isNotEmpty) {
        final response = await http
            .get(Uri.parse('http://192.168.1.117:4000/get_user/$userId'));
        if (response.statusCode == 200) {
          final userData = json.decode(response.body);
          setState(() {
            username = userData['user']['username'].toString();
          });
        } else {
          throw Exception('Failed to load user data');
        }
      } else {
        throw Exception('User ID not found in shared preferences');
      }
    } catch (error) {
      setState(() {
        _error = 'Failed to load user data: $error';
      });
    }
  }

  Future<void> _sendMessage(String message) async {
    const url = 'http://192.168.1.117:4000/messages';

    final newMessage = Message(
      user: userId,
      message: message,
      channel: widget.channel,
      university: widget.university,
      timestamp: DateTime.now(),
    );

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newMessage.toJson()),
      );

      if (response.statusCode == 201) {
        _controller.clear();
        fetchMessages(); // Refresh the message list after sending a new message
      } else {
        setState(() {
          _error = 'Failed to send message';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to send message: $e';
      });
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final DateFormat formatter = DateFormat('MMM d, yyyy h:mm a');
    return formatter.format(timestamp);
  }

  @override
  void dispose() {
    _socket?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Error: $_error'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: message.imageUrl != null
                                  ? NetworkImage(message.imageUrl!)
                                  : null,
                              backgroundColor: message.imageUrl == null
                                  ? Colors.blue
                                  : Colors.transparent,
                              child: message.imageUrl == null &&
                                      message.user.isNotEmpty
                                  ? Text(
                                      message.user[0].toUpperCase(),
                                      style: const TextStyle(color: Colors.white),
                                    )
                                  : null,
                            ),
                            title: Text(message.message),
                            subtitle: Text(
                              '${message.username ?? message.user} - ${_formatTimestamp(message.timestamp)}',
                              style:
                                  const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                    SlideTransition(
                      position: _offsetAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  focusColor: Colors.blue,
                                  hintText: 'Enter your message',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.blue),
                              onPressed: () => _sendMessage(_controller.text),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
