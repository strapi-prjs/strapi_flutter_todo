import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../GraphQLConfig.dart';

String readTodo = """
  query(\$id: ID!) {
  todo(id: \$id) {
    name
    done
  }
}
""";

String updateTodo = """
mutation(\$id: ID!, \$done: Boolean, \$name: String) {
  updateTodo(input: { where: { id: \$id }, data: { done: \$done, name: \$name } }) {
    todo {
      name
      done
    }
  }
}
""";

String deleteTodo = """
mutation(\$id: ID!) {
  deleteTodo(input: { where: { id: \$id } }) {
    todo {
      name
      done
    }
  }
}
""";

class ViewTodo extends StatefulWidget {
  final id;
  final refresh;
  ViewTodo({Key key, @required this.id, this.refresh}) : super(key: key);

  @override
  ViewTodoState createState() => ViewTodoState(id: id, refresh: this.refresh);
}

class ViewTodoState extends State<ViewTodo> {
  final id;
  final refresh;
  ViewTodoState({Key key, @required this.id, this.refresh});

  var editMode = false;
  var myController;
  bool done;

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
        client: GraphQLConfiguration.clientToQuery(),
        child: Query(
            options: QueryOptions(
              document: gql(readTodo),
              variables: {'id': id},
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

              // it can be either Map or List
              var todo = result.data["todo"];
              done = todo["done"];
              myController =
                  TextEditingController(text: todo["name"].toString());

              return Scaffold(
                appBar: AppBar(
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.blue,
                    flexibleSpace: SafeArea(
                        child: Container(
                            padding: EdgeInsets.only(
                                right: 16, top: 4, bottom: 4, left: 0),
                            child: Row(children: <Widget>[
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "View Todo",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ])))),
                body: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  width: double.infinity,
                  child: editMode
                      ? Column(
                          children: [
                            Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                                child: Text("Todo:",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ))),
                            TextField(
                              controller: myController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Add todo'),
                            ),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 0, 4),
                                      child: Text("Done:",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                          ))),
                                  StatefulBuilder(builder:
                                      (BuildContext context,
                                          StateSetter setState) {
                                    return new Checkbox(
                                      value: done,
                                      onChanged: (bool value) {
                                        print("done:" + done.toString());
                                        setState(() {
                                          done = value;
                                        });
                                      },
                                    );
                                  }),
                                ])
                          ],
                        )
                      : Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                              child: Text("Todo:",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  )),
                            ),
                            Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                                child: Text(todo["name"].toString(),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold))),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 4),
                              child: Text("Done:",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  )),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                              child: Text(todo["done"].toString(),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                ),
                floatingActionButton: !editMode
                    ? Mutation(
                        options: MutationOptions(
                          document: gql(deleteTodo),
                          update: (GraphQLDataProxy cache, QueryResult result) {
                            return cache;
                          },
                          onCompleted: (dynamic resultData) {
                            print(resultData);
                            refresh();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text('Done.')));
                            Navigator.pop(context);
                          },
                        ),
                        builder: (
                          RunMutation runMutation,
                          QueryResult result,
                        ) {
                          return Container(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                    child: FloatingActionButton(
                                      mini: true,
                                      heroTag: null,
                                      child: Icon(Icons.delete),
                                      onPressed: () {
                                        runMutation({'id': id});
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content:
                                                    Text('Deleting todo...')));
                                      },
                                    )),
                                FloatingActionButton(
                                  onPressed: () {
                                    setState(() {
                                      editMode = true;
                                    });
                                  },
                                  tooltip: 'Edit todo',
                                  child: Icon(Icons.edit),
                                )
                              ]));
                        })
                    : Mutation(
                        options: MutationOptions(
                          document: gql(updateTodo),
                          update: (GraphQLDataProxy cache, QueryResult result) {
                            return cache;
                          },
                          onCompleted: (dynamic resultData) {
                            print(resultData);
                            refresh();
                            refetch();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text('Done.')));
                          },
                        ),
                        builder: (
                          RunMutation runMutation,
                          QueryResult result,
                        ) {
                          return Container(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                    child: FloatingActionButton(
                                      mini: true,
                                      heroTag: null,
                                      child: Icon(Icons.cancel),
                                      onPressed: () {
                                        setState(() {
                                          editMode = false;
                                        });
                                      },
                                    )),
                                FloatingActionButton(
                                  heroTag: null,
                                  child: Icon(Icons.save),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text('Updating todo...')));
                                    runMutation({
                                      'id': id,
                                      'name': myController.text,
                                      'done': done
                                    });
                                    setState(() {
                                      editMode = false;
                                    });
                                  },
                                )
                              ]));
                        }),
              );
            }));
  }
}
