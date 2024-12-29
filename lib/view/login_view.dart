import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/user_model.dart';
import '../view_model/user_prefs_viewmodel.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoginConsumerClass(ref: ref);
  }
}

class LoginConsumerClass extends HookWidget {
  final WidgetRef ref;

  const LoginConsumerClass({required this.ref, super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useState(GlobalKey<FormState>());
    final userNameController = useTextEditingController();
    final emailController = useTextEditingController();
    final userViewModel = ref.read(userProvider.notifier);
    final userModel = ref.watch(userProvider);

    return Scaffold(
      body: mainBody(
        context,
        formKey,
        userNameController,
        emailController,
        userViewModel,
        userModel,
      ),
    );
  }

  SafeArea mainBody(
    BuildContext context,
    ValueNotifier<GlobalKey<FormState>> formKey,
    TextEditingController userNameController,
    TextEditingController emailController,
    UserPrefsViewMode userViewModel,
    UserModel userModel,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * .15),
              appTitleTextView(),
              SizedBox(height: MediaQuery.of(context).size.height * .02),
              loginTextView(context),
              const SizedBox(height: 10),
              formView(formKey, userNameController, emailController),
              const SizedBox(height: 10),
              getRegisterButton(
                formKey.value,
                userNameController,
                emailController,
                userViewModel,
                userModel,
                context,
              )
            ],
          ),
        ),
      ),
    );
  }

  Text appTitleTextView() {
    return const Text(
      "Task Management\nSystem",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
    );
  }

  Card formView(
    ValueNotifier<GlobalKey<FormState>> formKey,
    TextEditingController userNameController,
    TextEditingController emailController,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey.value,
          child: Column(
            children: [
              getTextFormFiled(
                controller: userNameController,
                labelText: 'Username',
                hintText: 'Enter your username',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username is required';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              getTextFormFiled(
                controller: emailController,
                labelText: 'Email',
                hintText: 'Enter your email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  // Regex for validating email
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton getRegisterButton(
    GlobalKey<FormState> formKey,
    TextEditingController userNameController,
    TextEditingController emailController,
    UserPrefsViewMode userViewModel,
    UserModel userModel,
    BuildContext context,
  ) {
    return ElevatedButton(
      onPressed: () {
        if (!formKey.currentState!.validate()) {
          return;
        }
        userViewModel.createUser(
          userName: userNameController.text.trim(),
          userEmail: emailController.text.trim(),
          context: context,
        );
      },
      style: ButtonStyle(
        fixedSize: WidgetStatePropertyAll(
          Size(MediaQuery.of(context).size.width, 52),
        ),
      ),
      child: const Text(
        "Register",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  getTextFormFiled({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) => validator(value),
    );
  }

  Text loginTextView(BuildContext context) {
    return const Text(
      "Register User",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.deepPurple,
      ),
    );
  }
}
