/// A single chat bubble — either a user text message, an AI text message,
/// or a GenUI surface placeholder rendered by [Surface].
class Message {
  Message.user(String this.text) : surfaceId = null, isUser = true;
  Message.aiText(String this.text) : surfaceId = null, isUser = false;
  Message.aiSurface(String this.surfaceId) : text = null, isUser = false;

  final String? text;
  final String? surfaceId;
  final bool isUser;
}
