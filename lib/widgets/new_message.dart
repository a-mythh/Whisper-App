import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// firebase
import 'package:cloud_firestore/cloud_firestore.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();

    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // send to Firebase
    FirebaseFirestore.instance.collection('chat').add({
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
      'createdAt': Timestamp.now(),
      'message': enteredMessage,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              minLines: 1,
              maxLines: 5,
              onEditingComplete: _submitMessage,
              controller: _messageController,
              autocorrect: true,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              enableSuggestions: true,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                  prefixIconColor: Theme.of(context).colorScheme.primary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(
                      width: 1.5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(
                      width: 1.5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  labelText: 'Send a message...',
                  alignLabelWithHint: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never),
            ),
          ),
          IconButton(
            onPressed: _submitMessage,
            icon: Icon(
              Icons.send_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
