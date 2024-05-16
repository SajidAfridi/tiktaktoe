import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'online_player_class.dart';

class MultiplayerService {
  final IO.Socket socket;

  MultiplayerService(String url)
      : socket = IO.io(url, IO.OptionBuilder()
      .setTransports(['websocket'])
      .setTimeout(10000)
      .build());

  void sendMove(int roomCode,movement) async{
    socket.emit('message', {
      'type': 'move',
      'code': roomCode,
      'symbol': movement.symbol,
      'move': movement.move,
    });
  }

  //stream the room turn if it is 0 or 1 and the symbol of the player only with room code
  int getRoomTurn(int roomCode){
    socket.emit('message', {
      'type': 'getRoomTurn',
      'code': roomCode,
    });
    socket.on('roomTurn', (data) {
      return data;
    });
    return 0;
  }

  Stream<Room>? get roomUpdates {
    // write the code to handle the following socket io broadcast.


    // roomUpdate is broadcast from server to all the users
    socket.on('roomUpdate', (data) {
      final room = Room.fromJson(data);
      // Add the received room object to a stream controller
      roomController.add(room);
    });
    return roomController.stream;
  }

  final roomController = StreamController<Room>.broadcast();
  void dispose() {
    roomController.close();
    socket.dispose();
  }

  void resetGame(int roomCode) {
    socket.emit('message', {
      'type': 'resetRoom',
      'code': roomCode,
      'turn': 0,
    });
  }
}
