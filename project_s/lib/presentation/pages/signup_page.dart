import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignUpRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacementNamed(context, '/home');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đăng ký thành công!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Đăng ký',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Họ và tên',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập họ và tên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!value.contains('@')) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is AuthLoadInProgress ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: const Color(0xFF7F3DFF),
                      ),
                      child: state is AuthLoadInProgress
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Đăng ký',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Đã có tài khoản? Đăng nhập'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}