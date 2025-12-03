import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  late final WebSocketChannel channel;

  WebSocketService(String url) {
    channel = WebSocketChannel.connect(Uri.parse(url));
  }

  void send(String message) {
    channel.sink.add(message);
  }

  void listen(void Function(dynamic message) onMessage) {
    channel.stream.listen(onMessage);
  }

  void dispose() {
    channel.sink.close();
  }
}
