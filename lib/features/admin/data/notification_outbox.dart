// Future-ready notification architecture.
// Wire FCM / email / WhatsApp adapters later — do not send from the UI yet.

enum NotificationKind {
  certificateReady,
  sessionReminder,
  upcomingSession,
  registrationConfirmation,
}

class NotificationRequest {
  const NotificationRequest({
    required this.kind,
    required this.studentIds,
    this.sessionId,
    this.payload = const {},
  });

  final NotificationKind kind;
  final List<String> studentIds;
  final String? sessionId;
  final Map<String, String> payload;
}

abstract class NotificationDispatcher {
  Future<void> enqueue(NotificationRequest request);
}

/// No-op dispatcher used until a real channel is connected.
class NoOpNotificationDispatcher implements NotificationDispatcher {
  final List<NotificationRequest> outbox = [];

  @override
  Future<void> enqueue(NotificationRequest request) async {
    outbox.add(request);
    // ignore: avoid_print
    print('[notifications] queued ${request.kind.name} '
        '→ ${request.studentIds.length} students');
  }
}
