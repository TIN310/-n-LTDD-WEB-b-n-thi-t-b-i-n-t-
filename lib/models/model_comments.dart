class Comment {
  final String username;
  final String text;
  final DateTime timestamp;

  Comment({required this.username, required this.text, required this.timestamp});
}

final List<Comment> sampleComment = [
  Comment(username: 'User1', text: 'Comment 1', timestamp: DateTime(2026, 1, 15)),
  Comment(username: 'User2', text: 'Comment 2', timestamp: DateTime(2026, 2, 5)),
  Comment(username: 'User3', text: 'Comment 3', timestamp: DateTime(2026, 4, 2)),
];