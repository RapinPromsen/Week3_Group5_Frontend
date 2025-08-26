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
      expenseMenu(userId);
    } else if (response.statusCode == 401  ||response.statusCode == 500) {
      stdout.write(response.body + "\n");
    } else {
      stdout.write("Unknown error\n");
    }
  });
}

void printExpenses(List<dynamic> expenses, String title,{bool showTotal = true}) {
  print("--------- $title ----------");
  int total = 0;

  for (var e in expenses) {
    int paid = e['paid'] as int;
    String formattedDate = e['date'].replaceAll('T', ' ').replaceAll('Z', '');
    total += paid;
    print("${e['id']}. ${e['item']}  : ${e['paid']}฿ : $formattedDate");
  }

 if (showTotal) {
    print("Total expenses = $total฿");
  }
}

Future<void> expenseMenu(int userId) async {
  while (true) {
    print("\n===== Expense Tracking App =====");
    print("1. Show all");
    print("2. Today's expense");
    print("3. Search expense");
    print("4. Add new expense");
    print("5. Delete an expense");
    print("6. Exit");

    stdout.write("Choose...");
    String? choose = stdin.readLineSync()?.trim();

    switch (choose) {
      case '1':
        final url = Uri.parse('http://localhost:3000/expenses?user_id=$userId');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          List<dynamic> expense = jsonDecode(response.body);
        } else {
          print("Error fetching expenses: ${response.statusCode}");
        }
        break;
    }
  }
}
