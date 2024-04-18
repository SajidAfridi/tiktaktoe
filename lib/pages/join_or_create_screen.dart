import 'dart:convert';
import 'dart:ffi';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:tiktaktoe/pages/play_with_friends_screen.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CreateOrJoinScreen extends StatefulWidget {
  const CreateOrJoinScreen({super.key});

  @override
  State<CreateOrJoinScreen> createState() => _CreateOrJoinScreenState();
}

class _CreateOrJoinScreenState extends State<CreateOrJoinScreen> {
  final _channel = WebSocketChannel.connect(
      Uri.parse('wss://few-coconut-bonnet.glitch.me/'));
  String? receivedCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/bg_image.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Tic Tak Toe',
                  style: TextStyle(
                    fontFamily: 'PermanentMarker',
                    fontSize: 40,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Create Or Join Room',
                  style: TextStyle(
                    fontFamily: 'PermanentMarker',
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                buildButton('Create Room', () {
                  codeReceiver();
                  _showCodeDialog(context);
                }),
                const SizedBox(
                  height: 20,
                ),
                buildButton('Join Room', () {
                  _showJoinDialog(context);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButton(String text, voidCallback) {
    return SizedBox(
      height: 80,
      child: ElevatedButton(
        onPressed: voidCallback,
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        child: ListTile(
          splashColor: colorDecider(text),
          leading: Container(
            height: 80,
            width: 60,
            decoration: BoxDecoration(
              color: colorDecider(text),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.circle_outlined,
              color: Colors.white,
            ),
          ),
          title: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              AutoSizeText(
                text,
                maxLines: 3,
                maxFontSize: 30,
                minFontSize: 20,
                style: const TextStyle(
                  fontFamily: 'PermanentMarker',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Color colorDecider(String difficultyText) {
    switch (difficultyText) {
      case 'Create Room':
        return Colors.green;
      case 'Join Room':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
  void _showJoinDialog(BuildContext context) {
    TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Game'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(labelText: 'Enter Room Code'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              String code = codeController.text;
              // Send join request with the entered code
              _channel.sink
                  .add(jsonEncode({'message': 'joinGame', 'code': code}));
              Navigator.of(context).pop();
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
  void codeReceiver() {
    _channel.sink.add(jsonEncode({'message': 'generateCode'}));
    // print('Sent message: generateCode');
    _channel.stream.listen((event) {
      final data = jsonDecode(event);
      handleMessage(data, _channel);
    });
  }
  void handleMessage(dynamic data, WebSocketChannel channel) {
    if (data is int) {
      print('Received data: $data');
      setState(() {
        receivedCode = data.toString();
      });
    } else if (data is Map<String, dynamic> && data.containsKey('message')) {
      final message = data['message'];
      if (message == 'generateCode') {
        // Generate a code and send it back to the user
        String code = generateCode();
        channel.sink.add(code);
        setState(() {
          receivedCode = code;
        });
      }
    }
  }
  String generateCode() {
    // Replace this with your actual code generation logic
    return "ABC123"; // Example code generation
  }
  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }


  //show the user the code generated for the room in the dialog and ask them to share it with their friend
  void _showCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Room Code'),
        content: Text(receivedCode ?? ''),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
