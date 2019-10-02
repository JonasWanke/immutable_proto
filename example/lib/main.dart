import 'package:immutable_proto/immutable_proto.dart';

import 'proto_generated/user.pb.dart' as proto;

part 'main.g.dart';

main() {
  final jane = User(
    firstName: 'Jane',
    lastName: 'Doe',
    emailAddresses: KtList.of('jane.doe@example.com'),
    favoriteDrink: UserFavoriteDrink.coffee,
  );
  print(jane);

  final john = jane.copy(
    firstName: 'John',
    emailAddresses: KtList.of('john.doe@example.com'),
    favoriteDrink: UserFavoriteDrink.tea,
  );
  print(john);
}

@ImmutableProto(proto.User)
class MutableUser {
  String firstName;

  @required
  String lastName;

  KtList<String> emailAddresses;

  proto.User_FavoriteDrink favoriteDrink;
}
