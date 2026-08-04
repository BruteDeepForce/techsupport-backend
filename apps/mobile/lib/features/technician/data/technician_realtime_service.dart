import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../auth/data/token_storage.dart';

class RealTimeTechnicianShiftService {
  RealTimeTechnicianShiftService(String hubUrl)
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
      debugPrint('Connected to technician shift updates');
    } catch (e) {
      debugPrint('Error connecting to technician shift updates: $e');
    }
  }

  Future<void> joinPersonalNotification() async {
    try {
      await _hubConnection.invoke('JoinPersonalNotification');
      debugPrint('Joined technician shift group:');
    } catch (e) {
      debugPrint('Error joining technician shift group: $e');
    }
  }

  void subscribeToTechnicianShiftUpdates(Function(List<Object?>?) onUpdate) {
    _hubConnection.off('ReceiveShiftCreateByAdmin');
    _hubConnection.on('ReceiveShiftCreateByAdmin', onUpdate);
  }

  void unsubscribeFromTechnicianShiftUpdates() {
    _hubConnection.off('ReceiveShiftCreateByAdmin');
  }

  Future<void> disconnect() async {
    try {
      await _hubConnection.stop();
      debugPrint('Disconnected from technician shift updates');
    } catch (e) {
      debugPrint('Error disconnecting from technician shift updates: $e');
    }
  }
}
