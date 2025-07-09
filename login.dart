import 'dart:io';

void main() {
  const String filePath = 'users.txt';

  // Load existing users from file
  Map<String, String> users = loadUsersFromFile(filePath);
  int loginAttempts = 0;
  bool isLoggedIn = false;
  String currentUser = '';

  // 🔄 Password change function
  void changePassword(Map<String, String> users, String username) {
    stdout.write('Do you want to change your password? (yes/no): ');
    String choice = stdin.readLineSync()!.toLowerCase();

    if (choice == 'yes' || choice == 'y') {
      stdout.write('Enter your new password: ');
      String newPass1 = stdin.readLineSync()!;
      stdout.write('Confirm your new password: ');
      String newPass2 = stdin.readLineSync()!;

      if (newPass1 == newPass2) {
        users[username] = newPass1;
        saveUsersToFile(users, filePath);
        print('✅ Password changed successfully for $username.');
      } else {
        print('❌ Passwords did not match. Password not changed.');
      }
    } else {
      print('👍 Password change skipped.');
    }
  }

  // 🔁 Main menu loop
  while (!isLoggedIn) {
    print('''\n========= MENU =========
\t1. Login
\t2. Register''');
    stdout.write('Choose an option (1 or 2): ');
    String menuChoice = stdin.readLineSync()!;

    if (menuChoice == '1') {
      // 🔐 Login process
      while (loginAttempts < 3 && !isLoggedIn) {
        stdout.write('Enter username: ');
        String enteredUsername = stdin.readLineSync()!;
        stdout.write('Enter password: ');
        String enteredPassword = stdin.readLineSync()!;

        if (users.containsKey(enteredUsername) &&
            users[enteredUsername] == enteredPassword) {
          isLoggedIn = true;
          currentUser = enteredUsername;
          print('\n✅ Login successful! Welcome, $currentUser.');
          changePassword(users, currentUser);
          break;
        } else {
          loginAttempts++;
          print('''❌ Login failed. worng userName or password. 
           Attempts left: ${3 - loginAttempts}''');
        }
      }

      if (!isLoggedIn && loginAttempts >= 3) {
        print('🔒 Account locked. Too many failed attempts.');
        break;
      }
    } else if (menuChoice == '2') {
      // 🧑 Register new user
      stdout.write('Enter a new username: ');
      String newUsername = stdin.readLineSync()!;

      if (users.containsKey(newUsername)) {
        print('❌ Username already exists. Try another.');
      } else {
        stdout.write('Enter new password: ');
        String password1 = stdin.readLineSync()!;
        stdout.write('Confirm new password: ');
        String password2 = stdin.readLineSync()!;

        if (password1 == password2) {
          users[newUsername] = password1;
          saveUsersToFile(users, filePath);
          print('✅ User "$newUsername" registered successfully.');

          // ✅ Ask if user wants to login right now
          stdout.write('Do you want to login now? (yes/no): ');
          String loginNow = stdin.readLineSync()!.toLowerCase();

          if (loginNow == 'yes' || loginNow == 'y') {
            stdout.write('Enter password again: ');
            String retryPassword = stdin.readLineSync()!;
            if (retryPassword == password1) {
              isLoggedIn = true;
              currentUser = newUsername;
              print('\n✅ Login successful! Welcome, $currentUser.');
              changePassword(users, currentUser);
              break;
            } else {
              print('❌ Wrong password. Please login from main menu.');
            }
          }
        } else {
          print('❌ Passwords did not match. Registration failed.');
        }
      }
    } else {
      print('❗ Invalid option. Please choose 1 or 2.');
    }
  }
}

// 📁 Load users from file
Map<String, String> loadUsersFromFile(String path) {
  Map<String, String> users = {};
  File file = File(path);

  if (file.existsSync()) {
    List<String> lines = file.readAsLinesSync();
    for (String line in lines) {
      List<String> parts = line.split(':');
      if (parts.length == 2) {
        users[parts[0]] = parts[1];
      }
    }
  } else {
    file.createSync();
  }

  return users;
}

// 💾 Save users to file
void saveUsersToFile(Map<String, String> users, String path) {
  File file = File(path);
  List<String> lines = [];

  users.forEach((username, password) {
    lines.add('$username:$password');
  });

  file.writeAsStringSync(lines.join('\n'));
}
