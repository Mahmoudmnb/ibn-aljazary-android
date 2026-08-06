class AppNotification {
  String id;
  String title;
  String body;

  AppNotification({required this.body, required this.id, required this.title});

  factory AppNotification.fromMap(Map data) {
    return AppNotification(
      body: data['body'],
      id: data['id'],
      title: data['title'],
    );
  }
  Map toMap() {
    return {'id': id, 'title': title, 'body': body};
  }
}
