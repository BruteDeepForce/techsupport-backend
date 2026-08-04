import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../auth/data/token_storage.dart';

class RealtimeTradeService {
  RealtimeTradeService(String hubUrl)
      : _tokenStorage = TokenStorage(),
        _hubConnection = HubConnectionBuilder()
            .withUrl(
              hubUrl,
              options: HttpConnectionOptions(
                accessTokenFactory: () async =>
                    await TokenStorage().getToken() ?? '',
              ),
            )
            .withAutomaticReconnect()
            .build();

  late final HubConnection _hubConnection;
  final TokenStorage _tokenStorage;

  Future<void> connect() async {
    try {
      if (_hubConnection.state == HubConnectionState.Connected) {
        return;
      }

      final token = await _tokenStorage.getToken();
      debugPrint('SignalR token present: ${token != null && token.isNotEmpty}');
      await _hubConnection.start();
      debugPrint('Connected to trade updates');
    } catch (e) {
      debugPrint('Error connecting to trade updates: $e');
    }
  }

  Future<void> joinTradeGroup(String tradeId) async {
    try {
      await _hubConnection.invoke('JoinTradeGroup', args: [tradeId]);
      debugPrint('Joined trade group: $tradeId');
    } catch (e) {
      debugPrint('Error joining trade group: $e');
    }
  }

  void subscribeToTradeUpdates(Function(List<Object?>?) onUpdate) {
    _hubConnection.off('ReceiveTradeStatusUpdate');
    _hubConnection.on('ReceiveTradeStatusUpdate', onUpdate);
  }

  void unsubscribeFromTradeUpdates() {
    _hubConnection.off('ReceiveTradeStatusUpdate');
  }

  Future<void> disconnect() async {
    try {
      await _hubConnection.stop();
      debugPrint('Disconnected from trade updates');
    } catch (e) {
      debugPrint('Error disconnecting from trade updates: $e');
    }
  }
}
