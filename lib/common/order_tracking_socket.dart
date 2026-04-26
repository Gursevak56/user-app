import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:food_delivery/common/globs.dart';

class OrderTrackingSocket {
  WebSocket? _socket;
  Timer? _reconnectTimer;
  final String orderId;
  final void Function(Map<String, dynamic> data) onMessage;
  final void Function() onDisconnected;
  final void Function() onConnected;

  bool _isDisposed = false;

  OrderTrackingSocket({
    required this.orderId,
    required this.onMessage,
    required this.onDisconnected,
    required this.onConnected,
  });

  void connect() async {
    if (_isDisposed) return;
    try {
      final token = Globs.getToken() as String;
      final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
      final url = SVKey.wsOrderStatus(sessionId, orderId);
      
      _socket = await WebSocket.connect(url, headers: {
        'Authorization': 'Bearer $token',
      });
      
      if (_isDisposed) {
        _socket?.close();
        return;
      }

      onConnected();

      _socket!.listen(
        (message) {
          try {
            final data = json.decode(message);
            onMessage(data);
          } catch (e) {
            if (kDebugMode) print('WS parse error: $e');
          }
        },
        onDone: () {
          _scheduleReconnect();
        },
        onError: (err) {
          _scheduleReconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (kDebugMode) print('WS connect error: $e');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_isDisposed) return;
    onDisconnected();
    _socket?.close();
    _socket = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      connect();
    });
  }

  void dispose() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _socket?.close();
    _socket = null;
  }
}
