// MultiplayerService.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MultiplayerService {
  final IO.Socket socket;

  MultiplayerService(String url)
      : socket = IO.io(url, IO.OptionBuilder()
      .setTransports(['websocket'])
      .setTimeout(10000)
      .build());

  void joinRoom(String roomCode) {
    socket.emit('join', {'code': roomCode,'turn':0,'symbol':'O'});
  }

  void sendMove(String roomCode, String symbol, String move) {
    socket.emit('message', {
      'type': 'move',
      'code': roomCode,
      'symbol': symbol,
      'move': move,
    });
  }

  //stream the room turn if it is 0 or 1 and the symbol of the player only with room code
  int getRoomTurn(String roomCode) {
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

  //check players turn i.e when the turn value in the room is 1 and the symbol is X then it should return true
  // if the turn value is 1 and the symbol is O then it should return false.
  // if the turn is 0 and the symbol is X then it should return false
  // if the turn is 0 and the symbol is O then it should return true
  bool isPlayerTurn(int turn, String symbol) {
    if(turn==1){
      return symbol=='X'?true:false;
    }else{
      return symbol=='O'?true:false;
    }
  }

  void dispose() {
    socket.dispose();
  }

}
