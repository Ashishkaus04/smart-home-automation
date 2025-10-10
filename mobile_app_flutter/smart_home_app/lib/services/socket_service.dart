import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  io.Socket? _socket;

  void connect(String baseUrl, {void Function()? onConnect}) {
    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .build(),
    );
    _socket!.onConnect((_) => onConnect?.call());
  }

  void onDeviceState(void Function(dynamic data) handler) {
    _socket?.on('deviceState', handler);
  }

  void onDeviceUpdate(void Function(dynamic data) handler) {
    _socket?.on('deviceUpdate', handler);
  }

  void onSensorUpdate(void Function(dynamic data) handler) {
    _socket?.on('sensorUpdate', handler);
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}


