// MultiplayerService.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'online_player_class.dart';

class MultiplayerService {
  final IO.Socket socket;

  MultiplayerService(String url)
      : socket = IO.io(url, IO.OptionBuilder()
      .setTransports(['websocket'])
      .setTimeout(10000)
      .build());

  void sendMove(int roomCode, String symbol, String move) {
    socket.emit('message', {
      'type': 'move',
      'code': roomCode,
      'symbol': symbol,
      'move': move,
    });
  }

  //stream the room turn if it is 0 or 1 and the symbol of the player only with room code
  int getRoomTurn(int roomCode){
    socket.emit('message', {
      'type': 'getRoomTurn',
      'code': roomCode,
    });
    socket.on('roomTurn', (data) {
      print('Room turn: $data');
      return data;
    });
    return 0;
  }
  Stream<dynamic>? get moveRegisteredStream{
    socket.on('moveRegistered', (data) {
      print('Move registered: on moveRegistered event');
      return data;
    });
    return null;
  }
  Stream<Room>? get roomUpdates {
    socket.on('roomUpdate', (data) {
      final room = Room.fromJson(data);
      print('Room updated: $room');
      return Stream.fromIterable([room]);
    });
    return null;
  }
  bool isPlayerTurn(int turn, String symbol) {
    if(turn==1){
      return symbol=='O'?true:false;
    }else{
      return symbol=='X'?true:false;
    }
  }
  void dispose() {
    socket.dispose();
  }

}
