import 'package:flutter/material.dart';
import 'dart:math';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'GraphQLConfig.dart';
import 'screens/CreateTodo.dart';

import 'screens/ViewTodo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
        client: GraphQLConfiguration.clientToQuery(),
        child: MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: TodoList(),
        ));
  }
}

class TodoList extends StatefulWidget {
  TodoList({Key key}) : super(key: key);

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  String readTodos = """
    query {
      todos(sort:"created_at:desc") {
        id
        name
        done
        created_at
      }
    }
  """;

  var colors = [
    Colors.amber,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.yellow
  ];
  Random random = new Random();
  var todos = [];

  randomColors() {
    int randomNumber = random.nextInt(colors.length);
    return colors[randomNumber];
  }

  onChanged(b) {
    return true;
  }

  queryTodos() async {
    var client = GraphQLClient(
      cache: GraphQLCache(),
      link: HttpLink(
        'http://10.0.2.2:1337/graphql',
      ),
    );
    final QueryResult r =
        await client.query(QueryOptions(document: gql(readTodos)));
    if (r.hasException) {
      print(r.exception.toString());
    }

    print(r);
  }

  @override
  Widget build(BuildContext context) {

    return Query(
        options: QueryOptions(
          document: gql(readTodos), // this is the query string you just created
          pollInterval: Duration(seconds: 0),
        ),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return Text('Loading');
          }

          todos = result.data["todos"];

          return Scaffold(
            body: Column(children: [
              Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(8, 50, 0, 9),
                  color: Colors.blue,
                  child: Text(
                    "Todo",
                    style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )),
              Expanded(
                  child: ListView.builder(
                itemCount: todos.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewTodo(
                              id: todos[index]["id"],
                              refresh: () {
                                refetch();
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          color: randomColors(),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 6, 0, 6),
                                    child: Text(
                                        todos[index]["name"]
                                            .toString() /*"Go to the grocery store"*/,
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Text(DateFormat("yMMMEd")
                                      .format(DateTime.parse(todos[index]
                                              ["created_at"]
                                          .toString()))
                                      .toString()),
                                ],
                              ),
                            ),
                            Checkbox(
                                value: todos[index]["done"],
                                onChanged: onChanged)
                          ],
                        ),
                      ));
                },
              ))
            ]),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateTodo(refresh: () {
                      refetch();
                    }),
                  ),
                );
              },
              tooltip: 'Add new todo',
              child: Icon(Icons.add),
            ),
          );
        });
  }
}
