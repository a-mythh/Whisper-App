import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

// widgets
import 'package:chat_app/widgets/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isAuthenticating = false;

  var _enteredUsername = '';
  var _enteredEmail = '';
  var _enteredPassword = '';
  File? _selectedImage;

  @override
  Widget build(context) {
    final formKey = GlobalKey<FormState>();

    void submit() async {
      final isValid = formKey.currentState!.validate();

      if (!isValid || (!_isLogin && _selectedImage == null)) {
        // show error message
        return;
      }

      formKey.currentState!.save();

      try {
        setState(() {
          _isAuthenticating = true;
        });

        if (_isLogin) {
          await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail,
            password: _enteredPassword,
          );
        } else {
          final userCredentials =
              await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail,
            password: _enteredPassword,
          );

          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child('${userCredentials.user!.uid}.jpg');

          await storageRef.putFile(_selectedImage!);
          final imageURL = await storageRef.getDownloadURL();

          // upload details to database
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredentials.user!.uid)
              .set({
            'username': _enteredUsername,
            'email': _enteredEmail,
            'image_url': imageURL,
          });
        }
      } on FirebaseAuthException catch (error) {
        if (error.code == 'INVALID_LOGIN_CREDENTIALS') {
          // ...
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                'Invalid user credentials',
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                error.message ?? 'Authentication failed.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        setState(() {
          _isAuthenticating = false;
        });
      }
    }

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(1),
            Theme.of(context).colorScheme.primary.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 150,
                child: Image.asset('assets/images/logo.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Avatar
                          if (!_isLogin)
                            UserImagePicker(
                              onPickImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),

                          // Username input
                          if (!_isLogin)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: TextFormField(
                                onSaved: (value) => _enteredUsername = value!,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim().length < 4) {
                                    return 'Please enter at least 4 characters.';
                                  }
                                  return null;
                                },
                                style: Theme.of(context).textTheme.titleMedium,
                                decoration: InputDecoration(
                                    labelText: 'Username',
                                    prefixIcon: const Icon(
                                      Icons.sentiment_satisfied_alt_rounded,
                                      size: 20,
                                    ),
                                    prefixIconColor:
                                        Theme.of(context).colorScheme.primary,
                                    labelStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                keyboardType: TextInputType.name,
                                enableSuggestions: false,
                              ),
                            ),
                          const SizedBox(
                            height: 16,
                          ),

                          // Email input
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextFormField(
                              onSaved: (value) => _enteredEmail = value!,
                              validator: (value) {
                                if ((value == null) ||
                                    value.trim().isEmpty ||
                                    !(value.contains('@') &&
                                        value.contains('.'))) {
                                  return 'Please enter a valid email address.';
                                }
                                return null;
                              },
                              style: Theme.of(context).textTheme.titleMedium,
                              decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(
                                    Icons.alternate_email_rounded,
                                    size: 20,
                                  ),
                                  prefixIconColor:
                                      Theme.of(context).colorScheme.primary,
                                  labelStyle:
                                      Theme.of(context).textTheme.titleMedium),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),

                          // Password input
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextFormField(
                              onSaved: (value) => _enteredPassword = value!,
                              validator: (value) {
                                if ((value == null) ||
                                    value.trim().length < 8) {
                                  return 'Password must be at least 8 characters long.';
                                }
                                return null;
                              },
                              style: Theme.of(context).textTheme.titleMedium,
                              decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    size: 20,
                                  ),
                                  suffixIcon: const Icon(
                                    Icons.visibility_off_rounded,
                                    size: 20,
                                  ),
                                  prefixIconColor:
                                      Theme.of(context).colorScheme.primary,
                                  labelStyle:
                                      Theme.of(context).textTheme.titleMedium),
                              obscureText: true,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Loading
                          if (_isAuthenticating) ...{
                            const CircularProgressIndicator(),
                            const SizedBox(
                              height: 10,
                            ),
                          },

                          // Not Loading
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(_isLogin ? 'Login' : 'Sign up'),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? 'Don\'t have an account?'
                                  : 'Already have an account?'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
