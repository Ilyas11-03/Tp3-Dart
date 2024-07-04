import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatbotPage extends StatefulWidget {
  ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  List messages = [
    {"message": "Hello", "type": "user"},
    {"message": "How can i help you ?", "type": "assistant"}
  ];

  TextEditingController queryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            "Chat Bot",
            style: TextStyle(color: Theme.of(context).indicatorColor),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            messages[index]['message'],
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: Theme.of(context).primaryColor,
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: queryController,
                    decoration: InputDecoration(
                        //icon: Icon(Icons.lock),
                        suffixIcon: Icon(Icons.visibility),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1,
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      var query = queryController.text;
                      var url =
                          Uri.https("api.openai.com", "/v1/chat/completions");
                      Map<String, String> headers = {
                        "Content-type": "application/json",
                      };
                      var prompt = {
                        "model": "gpt-3.5-turbo",
                        "messages": [
                          {"role": "user", "content": query}
                        ],
                        "temperature": 0.7
                      };
                      http
                          .post(url,
                              headers: headers, body: json.encode(prompt))
                          .then((resp) {
                        var responseBody = resp.body;
                        var llmresponse = json.decode(responseBody);
                        String responseContent =
                            llmresponse['choices'][0]['message']['content'];
                        setState(() {
                          messages.add({"message": query, "type": "user"});
                          messages.add({
                            "message": responseContent,
                            "type": "assistant"
                          });
                        });
                      }, onError: (err) {
                        print("++++++++++++ERROR++++++++++");
                        print(err);
                      });
                    },
                    icon: Icon(Icons.send))
              ],
            )
          ],
        ));
  }
}
