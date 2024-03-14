class HistoryList {
  final String? role;
  final String? content;

  HistoryList({this.role, this.content});

  @override
  String toString() {
    return "{role: $role, content: $content}";
  }
}
