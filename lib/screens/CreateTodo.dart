import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import './../GraphQLConfig.dart';

String addTodo = """
  mutation(\$name: String, \$done: Boolean) {
    createTodo(input: { data: { name: \$name, done: \$done } }) {
      todo {
        name
        done
      }
    }
  }
""";

class CreateTodo extends StatelessWidget {
  final myController = TextEditingController();
  final refresh;
  CreateTodo({Key key, this.refresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
        client: GraphQLConfiguration.clientToQuery(),
        child: Mutation(
            options: MutationOptions(
              document:
                  gql(addTodo), 
              update: (GraphQLDataProxy cache, QueryResult result) {
                return cache;
              },
              onCompleted: (dynamic resultData) {
                refresh();
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('New todo added.')));
                Navigator.pop(context);
              },
            ),
            builder: (
              RunMutation runMutation,
              QueryResult result,
            ) {
              return Scaffold(
                  appBar: AppBar(
                    title: Text("Create Todo"),
                  ),
                  body: Column(children: [
                    Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.fromLTRB(10, 50, 10, 9),
                        child: TextField(
                          controller: myController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Add todo'),
                        )),
                    Row(children: [
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: MaterialButton(
                                onPressed: () {
                                  runMutation({
                                    'name': myController.text,
                                    'done': false
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('Adding new todo...')));
                                },
                                color: Colors.blue,
                                padding: const EdgeInsets.all(17),
                                child: Text(
                                  "Add",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 20),
                                ),
                              )))
                    ])
                  ]));
            }));
  }
}
