import 'package:ace_routes/controller/http_connection.dart';
import 'package:ace_routes/controller/loginController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController loginController = Get.put(LoginController());
  // final HttpConnection _fetchData = HttpConnection();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  margin: const EdgeInsets.only(bottom: 24.0),
                  child: Image.asset(
                    'assets/images/logo.png', // Replace with your logo asset path
                    height: 200,
                  ),
                ),
                // Account Name Field
                Obx(() => TextField(
                      onChanged: (value) {
                        loginController.accountName.value = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Account Name',
                        errorText:
                            loginController.accountNameError.value.isNotEmpty
                                ? loginController.accountNameError.value
                                : null,
                        border: OutlineInputBorder(),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                      ),
                    )),
                const SizedBox(height: 16.0),
                // Worker ID Field
                Obx(() => TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        loginController.workerId.value = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Worker ID',
                        errorText:
                            loginController.workerIdError.value.isNotEmpty
                                ? loginController.workerIdError.value
                                : null,
                        border: OutlineInputBorder(),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                      ),
                    )),
                const SizedBox(height: 16.0),
                // Password Field with Eye Icon
                Obx(() => TextField(
                      onChanged: (value) {
                        loginController.password.value = value;
                      },
                      obscureText: !loginController.isPasswordVisible.value,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        errorText:
                            loginController.passwordError.value.isNotEmpty
                                ? loginController.passwordError.value
                                : null,
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            loginController.isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: loginController.togglePasswordVisibility,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                      ),
                    )),
                const SizedBox(height: 16.0),
                // Remember Me Checkbox
                Obx(() => Row(
                      children: [
                        Checkbox(
                          value: loginController.rememberMe.value,
                          onChanged: (value) {
                            loginController.rememberMe.value = value!;
                          },
                        ),
                        const SizedBox(width: 10),
                        const Text('Remember Me'),
                      ],
                    )),
                const SizedBox(height: 16.0),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: () {
                      print('Data received: fdf');
                      loginController.login(context);
                      print('Data received: ');
                      
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
