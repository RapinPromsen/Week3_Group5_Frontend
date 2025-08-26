import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

void main() {
  stdout.write("===== Login =====\n");
  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();
  if (username == null || password == null) {
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
    } else if (response.statusCode == 401 || response.statusCode == 500) {
      stdout.write(response.body + "\n");
    } else {
      stdout.write("Unknown error\n");
    }
  });
}

void printExpenses(
  List<dynamic> expenses,
  String title, {
  bool showTotal = true,
}) {
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
      case '2':
        final url = Uri.parse(
          'http://localhost:3000/expenses/today?user_id=$userId',
        );
        final response = await http.get(url);

        if (response.statusCode == 200) {
          List<dynamic> expenses = jsonDecode(response.body);
          printExpenses(expenses, "Today's Expenses");
        } else {
          print("Error fetching today's expenses");
        }
        break;
      case '3':
        stdout.write("Enter keyword to search: ");
        String? keyword = stdin.readLineSync()?.trim();

        if (keyword != null && keyword.isNotEmpty) {
          final url = Uri.parse(
            'http://localhost:3000/expenses/search?user_id=$userId&keyword=$keyword',
          );
          final response = await http.get(url);

          if (response.statusCode == 200) {
            List<dynamic> expenses = jsonDecode(response.body);
            if (expenses.isEmpty) {
              print("No expenses found for '$keyword'");
            } else {
              printExpenses(expenses, "Search result for '$keyword'");
            }
          } else {
            print("Error searching expenses");
          }
        }
          break;
        case '4':
        stdout.write("Enter item: ");
        String? item = stdin.readLineSync()?.trim();

        stdout.write("Enter amount: ");
        String? amountStr = stdin.readLineSync()?.trim();
        int? amount = int.tryParse(amountStr ?? "");

      if (item != null && item.isNotEmpty && amount != null) {
          final url = Uri.parse('http://localhost:3000/expenses');
          final body = {
            "user_id": userId.toString(),
            "item": item,
            "paid": amount.toString()
          };

          final response = await http.post(url, body: body);
          if (response.statusCode == 200) {
            print("Expense added successfully!");
          } else {
            print("Failed to add expense");
          }
        } else {
          print("Invalid input!");
        }
          break;
        case '5':
        stdout.write("Enter expense ID to delete: ");
        String? idStr = stdin.readLineSync()?.trim();
        int? id = int.tryParse(idStr ?? "");

        if (id != null) {
          final url = Uri.parse('http://localhost:3000/expenses/$id');
          final response = await http.delete(url);

          if (response.statusCode == 200) {
            print("Expense deleted successfully!");
          } else {
            print("Failed to delete expense");
          }
        } else {
          print("Invalid ID!");
        }
        break;
    }
  }
}
