import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import './foodKeywords.dart';
import '../registration/log_In.dart';

import './api_key.dart';

class ChatGPTScreen extends StatefulWidget {
  static const String routeName = '/chat';

  @override
  _ChatGPTScreenState createState() => _ChatGPTScreenState();
}


class _ChatGPTScreenState extends State<ChatGPTScreen> {
  final List<Message> _messages = [];
  final List<Message> _messageHistory = [];
  final TextEditingController _textEditingController = TextEditingController();
  bool _isTyping = false;
  bool _isLoading = false; // New flag to indicate loading
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late String userId;
  final String chatBotImageUrl = 'assets/images/paul-green-gohffgwydnm-unsplash-1-bg-7FF.png';
final String userImageUrl = 'assets/images/placeholder.png';

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
     // Add an initial welcome message
  _messages.add(Message(
    text:
        "I'm your nutrition assistant. You can ask me anything about food, diet, and nutrition.",
    isMe: false, // Assuming this is a system-generated message
  ));
    getMessageHistory();
  }
List<String> foodKeywords = FoodKeywords.foodKeywords;

void onSendMessage() async {
  String messageText = _textEditingController.text;
  Message message = Message(text: messageText, isMe: true);
  _textEditingController.clear();

  setState(() {
    _messages.insert(0, message);
    _isTyping = true;
    _isLoading = true;
  });

  String response = await sendMessageToChatGpt(messageText);

  if (response != "Please ask a question related to food, diet, or nutrition.") {
    Message chatGpt = Message(text: response, isMe: false);

    firestore.collection('Chat').doc(userId).collection('Answer').add({
      'question': messageText,
      'answer': response,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _messages.insert(0, chatGpt);
      _isTyping = false;
      _isLoading = false;
    });
  } else {
    Message defaultResponse = Message(text: response, isMe: false);

    setState(() {
      _messages.insert(0,defaultResponse );
      _isTyping = false;
      _isLoading = false;
    });
  }
}



  Future<String> sendMessageToChatGpt(String message) async {
  // Check if the message contains any food-related keywords
  bool containsFoodKeyword = foodKeywords.any((keyword) => message.toLowerCase().contains(keyword));

  if (!containsFoodKeyword) {
    return "Please ask a question related to food, diet, or nutrition.";
  }

  Uri uri = Uri.parse("https://api.openai.com/v1/chat/completions");

  Map<String, dynamic> body = {
    "model": "gpt-3.5-turbo",
    "messages": [
      {"role": "user", "content": message}
    ],
    "max_tokens": 500,
  };

  final response = await http.post(
    uri,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${APIKey.apiKey}",
    },
    body: json.encode(body),
  );

  Map<String, dynamic> parsedResponse = json.decode(response.body);
  String reply = "";

  if (parsedResponse != null &&
      parsedResponse.containsKey('choices') &&
      parsedResponse['choices'].length > 0 &&
      parsedResponse['choices'][0].containsKey('message') &&
      parsedResponse['choices'][0]['message'].containsKey('content')) {
    reply = parsedResponse['choices'][0]['message']['content'];
  }

  return reply;
}

  void getMessageHistory() {
  firestore
      .collection('Chat')
      .doc(userId)
      .collection('Answer')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .listen((querySnapshot) {
    _messageHistory.clear();
    querySnapshot.docs.forEach((doc) {
      String question = doc['question'];
      String answer = doc['answer'];
      
      Message userQuestion = Message(text: question, isMe: true);
      Message chatbotAnswer = Message(text: answer, isMe: false);

      _messageHistory.add(userQuestion);
      _messageHistory.add(chatbotAnswer);
    });

    setState(() {}); // Ensure the UI is updated after modifying the _messageHistory list
  });
}


Widget _buildMessage(Message message) {
  final isMe = message.isMe;

  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (!isMe) // Show user icon only for non-user messages
          CircleAvatar(
            backgroundColor: Colors.green, // Adjust as needed
            child: Icon(
              Icons.android,
              color: Colors.white,
            ),
          ),
        if (!isMe) // Add some space between icon and message
          SizedBox(width: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  borderRadius: isMe ? BorderRadius.only(topLeft: Radius.circular(20.0), bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)) : BorderRadius.only(topRight: Radius.circular(20.0), bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
                  color: isMe ? Colors.blueGrey[100] : Colors.grey[200],
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (!isMe) // Show 'NutroAssist' for non-user messages
                      Text(
                        'NutroAssist',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 16.0,
                        ),
                      ),
                    SizedBox(height: 8.0),
                    Text(
                      message.text,
                      style: TextStyle(
                        color: isMe ? Colors.grey[800] : Colors.black,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isMe) // Add user icon after the message for user messages
          SizedBox(width: 8.0),
        if (isMe) // Show user icon only for user messages
          CircleAvatar(
            backgroundColor: Colors.blue, // Adjust as needed
            child: Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
      ],
    ),
  );
}


 Widget _buildMessageHistory() {
  return ListView.builder(
    itemCount: _messageHistory.length,
    itemBuilder: (BuildContext context, int index) {
      final message = _messageHistory[index];
      final isUser = message.isMe;

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (!isUser) // Show user icon only for non-user messages
              CircleAvatar(
                backgroundColor: Colors.green, // Adjust as needed
                child: Icon(
                  Icons.android,
                  color: Colors.white,
                ),
              ),
            if (!isUser) // Add some space between icon and message
              SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      borderRadius: isUser
                          ? BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              bottomLeft: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0),
                            )
                          : BorderRadius.only(
                              topRight: Radius.circular(20.0),
                              bottomLeft: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0),
                            ),
                      color: isUser ? Colors.blueGrey[100] : Colors.grey[200],
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (!isUser) // Show 'NutroAssist' for non-user messages
                          Text(
                            'NutroAssist',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 16.0,
                            ),
                          ),
                        SizedBox(height: 8.0),
                        Text(
                          message.text,
                          style: TextStyle(
                            color: isUser ? Colors.grey[800] : Colors.black,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isUser) // Add user icon after the message for user messages
              SizedBox(width: 8.0),
            if (isUser) // Show user icon only for user messages
              CircleAvatar(
                backgroundColor: Colors.blue, // Adjust as needed
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      );
    },
  );
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFF16336D), const Color(0xFF0B1C3E)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8.0,
              bottom: MediaQuery.of(context).size.height * 0.12,
            ),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: Icon(Icons.exit_to_app),
                                        color: Colors.white,

                      onPressed: () {
                        FirebaseAuth.instance.signOut(); // Log out the user
                        // Navigate to the login or home screen after logout
                        // For instance, if you have a login screen route named '/login':
                        Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildMessage(_messages[index]);
                    },
                  ),
                ),
                // Add other widgets if needed below the ListView
              ],
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8.0,
          right: 8.0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(222, 38, 51, 197),
            ),
            padding: EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(
                Icons.history,
                size: 32.0,
                color: Colors.white,
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return _buildMessageHistory();
                  },
                );
              },
            ),
          ),
        ),
        if (_isTyping || _isLoading) // Show typing/loading indicator
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12.0,
                  height: 12.0,
                  margin: EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    color: _isLoading
                        ? Colors.blue // Loading color
                        : Colors.blue, // Typing color
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 12.0,
                  height: 12.0,
                  margin: EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    color: _isLoading
                        ? Colors.blue // Loading color
                        : Colors.blue, // Typing color
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 12.0,
                  height: 12.0,
                  margin: EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
    bottomSheet: Container(
  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
  child: Row(
    children: <Widget>[
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(24.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0,),
          child: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              hintText: 'Type a message...',
              border: InputBorder.none,
            ),
          ),
        ),
      ),
      SizedBox(width: 8.0),
      Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(24.0),
          onTap: _isLoading ? null : onSendMessage,
          child: Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: _isLoading ? Colors.grey[400] : Colors.blueAccent,
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: _isLoading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  )
                : Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    ],
  ),
),

  );
}
}
class Message {
  final String text;
  final bool isMe;

  Message({required this.text, required this.isMe});
}
