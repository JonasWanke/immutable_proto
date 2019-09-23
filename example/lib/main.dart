import 'package:immutable_proto/immutable_proto.dart';

import 'proto_generated/user.pb.dart' as proto;

part 'main.g.dart';

main() {
  final user = MutableUser()..firstName = 'a';
}

@ImmutableProto(proto.User)
class MutableUser {
  String firstName;

  @required
  String lastName;

  KtList<String> emailAddresses;

  KtList<proto.User_FavoriteDrink> favoriteDrinks;
}
