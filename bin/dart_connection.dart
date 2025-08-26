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
          printExpenses(expense, "All Expenses"); //little bug 
        } else {
          print("Error fetching expenses: ${response.statusCode}");
        }

      case '2':
        final today = DateTime.now();
        final todayStr = "${today.year}-${today.month}-${today.day}";
        final todayUrl = Uri.parse('http://localhost:3000/expenses?user_id=$userId&date=$todayStr');
        final todayResp = await http.get(todayUrl);

        if (todayResp.statusCode == 200) {
          List<dynamic> todayExpenses = jsonDecode(todayResp.body);
          printExpenses(todayExpenses, "Today's Expenses", showTotal: false);
        } else {
          print("Error fetching today's expenses: ${todayResp.statusCode}");
        }
        break;
      case '3':
        stdout.write("Item to search:");
        String? keyword = stdin.readLineSync();

        if (keyword != null && keyword.isNotEmpty) {
          final url = Uri.parse('http://localhost:3000/expenses?user_id=$userId');
          final response = await http.get(url);

          if (response.statusCode == 200) {
            List<dynamic> allExpenses = jsonDecode(response.body);

            var results = allExpenses.where((e) =>
                (e['item'] as String).toLowerCase().contains(keyword.toLowerCase())).toList();

            if (results.isEmpty) {
              print("No items: \"$keyword\"");
            } else {
              printExpenses(results, "", showTotal: false);
            }
          } else {
            print("Error fetching expenses: ${response.statusCode}");
          }
        }
        break;
          case '4':
        stdout.write("Item: ");
        String? item = stdin.readLineSync()?.trim();
        stdout.write("Paid: ");
        String? paidStr = stdin.readLineSync()?.trim();
        int? paid = int.tryParse(paidStr ?? '');
        if (item == null || item.isEmpty || paid == null) {
          print("Invalid input. Item cannot be empty and Paid must be a number.");
          break;
        }
        final url = Uri.parse('http://localhost:3000/expenses/add');
        final body = {
          "user_id": userId.toString(),
          "item": item,
          "paid": paid.toString()
        };

        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
        if (response.statusCode == 201) {
          print("Expense added successfully.");
        } else {
          print("Error adding expense: ${response.statusCode}");
        }
        break;

        case '5':
        stdout.write("Item id: ");
        String? idStr = stdin.readLineSync()?.trim();
        int? expenseId = int.tryParse(idStr ?? '');

        if (expenseId == null) {
          print("Invalid input. Please enter a number.");
          break;
        }

        final delUrl = Uri.parse('http://localhost:3000/expenses/$expenseId');
        final delResp = await http.delete(delUrl);

        if (delResp.statusCode == 200) {
          print("Deleted!");
        } else if (delResp.statusCode == 404) {
          print("Expense not found.");
        } else {
          print("Error deleting expense: ${delResp.statusCode}");
        }
        break;

       case '6':
        stdout.write("----- Bye -------\n");
        return;

      default:
        stdout.write("Invalid choice, try again.\n");
    }
  }
}
