import 'package:flutter/material.dart';
import 'package:myapp/components/responsive.dart';
import '../components/socal_sign_up.dart';
import '../../components/background.dart';
import 'components/login_form.dart';
import 'components/login_screen_top_image.dart';

// Assuming 'responsive.dart' and 'background.dart' are in the parent directory's components folder
// And LoginForm and LoginScreenTopImage are in a 'components' subfolder within the same directory as this file.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Background(
      child: SingleChildScrollView(
        child: Responsive(
          mobile: MobileLoginScreen(),
          desktop: Row(
            children: [
              Expanded(child: LoginScreenTopImage()),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(width: 450, child: LoginForm()),
                        SocalSignUp(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MobileLoginScreen extends StatelessWidget {
  const MobileLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        LoginScreenTopImage(),
        Row(
          children: [Spacer(), Expanded(flex: 8, child: LoginForm()), Spacer()],
        ),
        SocalSignUp(),
      ],
    );
  }
}
