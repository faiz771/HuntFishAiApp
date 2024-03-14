class Message {
  final String? id;
  final bool isBot;
  String? message;
  final bool feedback;

  Message({this.id, this.isBot = true, this.message, this.feedback = false});
}
