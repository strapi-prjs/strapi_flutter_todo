import "package:flutter/material.dart";
import "package:graphql_flutter/graphql_flutter.dart";

class GraphQLConfiguration {
    static HttpLink httpLink = HttpLink(
      'http://10.0.2.2:1337/graphql',
    );

    static ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(),
        link: httpLink,
      ),
    );

   static ValueNotifier<GraphQLClient> clientToQuery() {
    return client;
  }
}
