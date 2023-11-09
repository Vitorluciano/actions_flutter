import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:posts_app/model/post.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController prefController = TextEditingController();
  String baseUrl = "https://jsonplaceholder.typicode.com";

  Future<List<Post>> getPosts() async {
    final response = await http.get(Uri.parse(baseUrl + "/posts"));
    
    var postJson = jsonDecode(response.body);
    List<Post> postList = [];

    for (var item in postJson) {
      postList.add(Post.fromJson(item));
    } 

    return postList;
  }

  void _post() async {
    http.Response response = await http.post(
      Uri.parse(baseUrl + "/posts"),
      headers: {
        "Content-type": "application/json; charset=UTF-8"
      },
      body: jsonEncode({
        "userId": 120,
        "id": null,
        "title": "Postagem de Teste",
        "body": "Exemplo de body"
      })
    );

    print(response.statusCode.toString());
    print(response.body);
  }

  void _put() async {
    http.Response response = await http.put(
      Uri.parse(baseUrl + "/posts/1"),
      headers: {
        "Content-type": "application/json; charset=UTF-8"
      },
      body: jsonEncode({
        "userId": 120,
        "id": null,
        "title": "Postagem de Teste",
        "body": "Exemplo de body"
      })
    );

    print(response.statusCode.toString());
    print(response.body);  
  }

  void _patch() async {
    http.Response response = await http.patch(
      Uri.parse(baseUrl + "/posts/1"),
      headers: {
        "Content-type": "application/json; charset=UTF-8"
      },
      body: jsonEncode({
        "id": null,
        "title": "Postagem de Teste",
      })
    );

    print(response.statusCode.toString());
    print(response.body);
  }

  void _delete() async {
    http.Response response = await http.delete(
      Uri.parse(baseUrl + "/posts/1"),
    );

    print(response.statusCode.toString());
    print(response.body);
  }

  void _saveSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("Shared_data", prefController.text);

  }

  void _getSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    String? sharedData = prefs.getString("shared_data");
    prefController.text = sharedData!;
  }

  @override
  Widget build(BuildContext context) {
    getPosts();
    return Scaffold(
      appBar: AppBar(title: const Text("Posts App")),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: prefController,
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _post, 
                    child: Text("Salvar")
                  ),
                  ElevatedButton(
                    onPressed: _put, 
                    child: Text("Atualizar")
                  ),
                  ElevatedButton(
                    onPressed: _delete, 
                    child: Text("Remover")
                  ),
                  ElevatedButton(
                    onPressed: _saveSharedPreferences, 
                    child: Text("Shared Preferences")
                  ),
                  ElevatedButton(
                    onPressed: _getSharedPreferences, 
                    child: Text("Shared Preferences")
                  ),
                ],
              ),

              FutureBuilder<List<Post>>(
                future: getPosts(), 
                builder: (context, snapshot) {

                  switch(snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                      break;
                    case ConnectionState.active:
                    case ConnectionState.done:
                      if(snapshot.hasError) {
                        print("Erro ao carregar");
                      } else {
                        List<Post>? posts = snapshot.data;

                        return Expanded(
                          flex: 2,
                          child: ListView.builder(
                            itemCount: posts!.length,
                            itemBuilder: (context, index) {
                              Post post = posts[index];

                              return ListTile(
                            
                                title: Text(post!.title),
                                leading: Text(post.id.toString()),
                                subtitle: Text(post.userId.toString()),
                                onTap: () {
                                  showDialog(
                                    context: context, 
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(post.title),
                                        content: Column(
                                          children: [
                                            Text(post.id.toString()),
                                            Text(post.body)
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              //desempilha a janelinha
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Fechar")
                                          )
                                        ]
                                      );
                                    }
                                  );
                                },

                              );
                            },
                          )
                        );
                      }
                    return const Text("Sem carregamento");
                    break;
                  }
                },
              )
            ]
            ),
        )
      ),
    );
  }
}