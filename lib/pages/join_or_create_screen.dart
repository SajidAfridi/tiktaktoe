import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tiktaktoe/pages/play_with_friends_screen.dart';

import '../classes/online_player_class.dart';

class CreateOrJoinScreen extends StatefulWidget {
  const CreateOrJoinScreen({super.key});

  @override
  State<CreateOrJoinScreen> createState() => _CreateOrJoinScreenState();
}

class _CreateOrJoinScreenState extends State<CreateOrJoinScreen> {
  String? receivedCode;
  FocusNode textFocus = FocusNode();
  TextEditingController codeController = TextEditingController();

  final IO.Socket socket = IO.io(
      'https://spiny-trite-breeze.glitch.me/',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setTimeout(20000)
          .build());

  @override
  void initState() {
    initSocket();
    super.initState();
  }

  void initSocket() {
    socket.connect();
    socket.onConnect((_) {
      print('Connection established');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  // Emit message with room creation data
                  createRoom();
                  //Listen for server response about room creation
                  socket.on('RoomCreated', (data) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MultiplayerScreen(
                          room: Room(
                            // Extract details from server response (assuming data structure)
                            code: data,
                            players: [
                              Player(symbol: 'X', move: '0', socketId: ''),
                              Player(symbol: 'O', move: '0', socketId: ''),
                            ],
                            // Player2 details
                            turn: 0, moves: [],
                          ),
                          isHost: true,
                        ),
                      ),
                    );
                  });
                }),
                const SizedBox(
                  height: 20,
                ),
                buildButton('Join Room', () {
                  _showJoinDialog(context);
                  FocusScope.of(context).requestFocus(textFocus);
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

  void _showJoinDialog(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          Future.delayed(const Duration(milliseconds: 100), () {
            FocusScope.of(context).requestFocus(textFocus);
          });
          return AlertDialog(
            title: const Center(
              child: Text(
                'Join Game',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            content: TextField(
              focusNode: textFocus, // Assign the FocusNode to the TextField
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Enter Room Code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  socket.connect();
                  socket.emit('message', {
                    'type': 'join',
                    'code': int.parse(codeController.text),
                    'turn': 1,
                    'symbol': 'O',
                    'move': '0',
                  });
                  socket.on('Successfully Joined', (data) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MultiplayerScreen(
                          room: Room(
                            code: data,
                            turn: 1,
                            moves: [],
                            players: [
                              Player(symbol: '', move: '0', socketId: ''),
                              Player(symbol: 'O', move: '0', socketId: ''),
                            ],
                          ),
                          isHost: false,
                        ),
                      ),
                    );
                  });
                  socket.on('Unsuccessfully Joined', (data) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(data),
                      ),
                    );
                  });
                },
                child: const Text('Join'),
              ),
            ],
          );
        });
  }

  void createRoom() {
    socket.emit('message', {
      'type': 'create',
      'turn': 0,
      'symbol': 'X',
      'move': '0',
    });
  }
}
