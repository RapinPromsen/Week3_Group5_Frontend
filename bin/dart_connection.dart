import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

void main() {
stdout.write("===== Login =====\n");
  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();
  if (username == null  ||password == null) {
    stdout.write("Incomplete input\n");
    return;
  }

  final body = {"username": username, "password": password};
  final url = Uri.parse('http://localhost:3000/login');

  http.post(url, body: body).then((response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final int userId = data['user_id'];
    } else if (response.statusCode == 401  ||response.statusCode == 500) {
      stdout.write(response.body + "\n");
    } else {
      stdout.write("Unknown error\n");
    }
  });
}