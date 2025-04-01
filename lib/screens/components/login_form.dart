import 'package:flutter/material.dart';
import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../screens/signup_screen.dart';
import 'package:myapp/api/api_client.dart';
import 'package:myapp/api/api_endpoints.dart';
import 'package:go_router/go_router.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiClient = ApiClient();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            decoration: const InputDecoration(
              hintText: "Username",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              decoration: const InputDecoration(
                hintText: "Password",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(height: defaultPadding),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _errorMessage = null;
              });

              try {
                final response = await _apiClient.login(
                  ApiEndpoints.login(),
                  data: {
                    'username': _usernameController.text,
                    'password': _passwordController.text,
                  },
                );

                print("Respuesta del servidor: $response");

                // ✅ Verifica si la clave "access_token" existe
                if (response.containsKey('access_token')) {
                  print("¡Inicio de sesión exitoso! Token: ${response['access_token']}");
                  GoRouter.of(context).goNamed('main');  // Navega a la pantalla principal
                } else {
                  setState(() {
                    _errorMessage = 'Unexpected response format: $response';
                  });
                }
              } catch (e) {
                setState(() {
                  _errorMessage = "Error: $e";
                });
              }
            },
            child: Text("Login".toUpperCase()),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SignUpScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
