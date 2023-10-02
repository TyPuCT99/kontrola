import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './home_page.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final TextEditingController passwordController = TextEditingController();
  bool isAuthenticated = false;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  void checkPasswordAndAuthenticate() async {
    String? savedPassword = await secureStorage.read(key: 'password');

    if (savedPassword != null && savedPassword == passwordController.text) {
      setState(() {
        isAuthenticated = true;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Czy ustawić nowe hasło?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setNewPassword();
                },
                child: const Text("Tak"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  enterApplication();
                },
                child: const Text("Nie"),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Błąd uwierzytelniania"),
            content: const Text("Nieprawidłowe hasło. Spróbuj ponownie."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  void authenticate() {
    checkPasswordAndAuthenticate();
  }

  void setPassword() async {
    String newPassword = passwordController.text;
    await secureStorage.write(key: 'password', value: newPassword);
    if (kDebugMode) {
      print('Hasło ustawione: $newPassword');
    }
  }

  void setNewPassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ustaw nowe hasło"),
          content: Column(
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration:
                const InputDecoration(labelText: 'Wprowadź nowe hasło'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setPassword();
                  Navigator.of(context).pop();
                },
                child: const Text('Ustaw nowe hasło'),
              ),
            ],
          ),
        );
      },
    );
  }

  void enterApplication() {
    setState(() {
      isAuthenticated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isAuthenticated) {
      return MyHomePage();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Uwierzytelnianie'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Hasło'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: authenticate,
                    child: const Text('Uwierzytelnij'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
}
