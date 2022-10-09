import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc/login_bloc.dart';

class LogInView extends StatelessWidget {
  const LogInView({key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar sesión")),
      body: Center(
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: ((context, state) {
            if (state is LoginInProgress) {
              return const CircularProgressIndicator();
            } else if (state is LoggedInSuccessful) {
              return const Text("Bienvenido");
            } else {
              return TextButton(
                onPressed: () {
                  context.read<LoginBloc>().add(
                        LoginPressed(),
                      );
                },
                child: const Text("Iniciar"),
              );
            }
          }),
        ),
      ),
    );
  }
}
