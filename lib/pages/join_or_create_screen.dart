import 'dart:async';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tiktaktoe/pages/play_with_friends_screen.dart';
import 'package:tiktaktoe/pages/welcome_and_difficulty_selection_screen.dart';
import '../classes/online_player_class.dart';

class CreateOrJoinScreen extends StatefulWidget {
  const CreateOrJoinScreen({super.key});

  @override
  State<CreateOrJoinScreen> createState() => _CreateOrJoinScreenState();
}

class _CreateOrJoinScreenState extends State<CreateOrJoinScreen> {
  bool isButtonEnabled = true;
  String? receivedCode;
  FocusNode textFocus = FocusNode();
  TextEditingController codeController = TextEditingController();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;


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
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void initSocket() {
    socket.connect();
    socket.onConnect((_) {
      print('Connection established');
    });
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
    socket.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (value) {
        socket.disconnect();
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (context) {
          return const SelectDifficultyScreen();
        }), (route) => false);
      },
      child: Scaffold(
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
              padding: EdgeInsets.symmetric(
                horizontal: 50.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20.h,
                  ),
                  Text(
                    'Tic Tak Toe',
                    style: TextStyle(
                      fontFamily: 'PermanentMarker',
                      fontSize: 40.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text(
                    'Create Or Join Room',
                    style: TextStyle(
                      fontFamily: 'PermanentMarker',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  buildButton('Create Room', () {
                    // Emit message with room creation data
                    createRoom();
                    //Listen for server response about room creation
                    socket.on('RoomCreated', (data) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MultiplayerScreen(
                                room: Room(
                                  // Extract details from server response (assuming data structure)
                                  code: data,
                                  players: [
                                    Player(
                                        symbol: 'X', move: '0', socketId: ''),
                                    Player(
                                        symbol: 'O', move: '0', socketId: ''),
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
                  SizedBox(
                    height: 20.h,
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
      ),
    );
  }

  Widget buildButton(String text, voidCallback) {
    return Container(
      height: 100.h,
      padding: EdgeInsets.symmetric(
        horizontal: 0.h,
      ),
      child: ElevatedButton(
        onPressed: isButtonEnabled ? () {
          if (_connectionStatus.contains(ConnectivityResult.none)) {
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              duration: const Duration(seconds: 3),
              content: AwesomeSnackbarContent(
                title: 'No Internet Connection',
                message: 'Please check your internet connection and try again.',
                contentType: ContentType.failure,
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else {
            voidCallback();
            setState(() {
              isButtonEnabled = false;
            });
            Timer(const Duration(seconds: 4), () {
              setState(() {
                isButtonEnabled = true;
              });
            });
          }
        } : null,
        child: ListTile(
          splashColor: colorDecider(text),
          leading: Container(
            height: 80.h,
            width: 60.w,
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
              SizedBox(
                width: 20.w,
              ),
              Text(
                text,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 23.sp,
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
              focusNode: textFocus,
              // Assign the FocusNode to the TextField
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Enter Room Code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (value) async {
                FocusScope.of(context).unfocus();
                // Reset focus within the dialog
                FocusScope.of(context).requestFocus(FocusNode());
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
                      builder: (context) =>
                          MultiplayerScreen(
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
                  final materialBanner = SnackBar(
                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    duration: const Duration(seconds: 3),
                    content: AwesomeSnackbarContent(
                      titleFontSize: 22.sp,
                      messageFontSize: 18.sp,
                      title: 'Unsuccessful Join',
                      message:
                      'The room code you entered is invalid. Please try again.',
                      contentType: ContentType.warning,
                      // to configure for material banner
                      inMaterialBanner: true,
                    ),
                  );
                  ScaffoldMessenger.of(context)
                      .hideCurrentSnackBar();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(materialBanner)
                      .closed
                      .then((_) {
                    // Navigate to a new screen or perform any other action here
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateOrJoinScreen()),
                          (route) => false,
                    );
                  });
                });
              },
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
                        builder: (context) =>
                            MultiplayerScreen(
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
                },
                child: const Text('Join'),
              ),
            ],
          );
        });
  }


  Future<void> createRoom() async {
    return Future.delayed(const Duration(seconds: 2), () {
      socket.emit('message', {
        'type': 'create',
        'turn': 0,
        'symbol': 'X',
        'move': '0',
      });
    });
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status, error: $e');
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });

    if (_connectionStatus.contains(ConnectivityResult.none)) {
      final materialBanner = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 3),
        content: AwesomeSnackbarContent(
          titleFontSize: 22.sp,
          messageFontSize: 18.sp,
          title: 'No Internet Connection',
          message:
          'Please check your internet connection and try again.',
          contentType: ContentType.failure,
          // to configure for material banner
          inMaterialBanner: true,
        ),
      );
      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(materialBanner)
          .closed
          .then((_) {
        // Navigate to a new screen or perform any other action here
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SelectDifficultyScreen()),
              (route) => false,
        );
      });
    }

    // ignore: avoid_print
    print('Connectivity changed: $_connectionStatus');
  }
}
