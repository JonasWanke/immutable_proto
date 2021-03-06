This library generates immutable data classes for Protocol Buffers. Here's how to get started:

1. Add these packages to your dependencies:
```yaml
dependencies:
  immutable_proto: ^0.1.0

dev_dependencies:
  build_runner: ^1.8.1
  immutable_proto_generator: ^0.1.0
```

2. Write your Protocol Buffers definition:
```protobuf
message User {
  string first_name = 1;

  string last_name = 2;

  repeated string email_addresses = 3;

  enum FavoriteDrink {
    UNKNOWN = 0;
    COFFEE = 1;
    COKE = 2;
    TEA = 3;
  }
  FavoriteDrink favorite_drink = 4;
}
```

3. Generate the default (mutable) dart code for your Protobuf message (see the [official documentation](https://developers.google.com/protocol-buffers/docs/darttutorial#compiling-your-protocol-buffers) for more information).

4. Write a blueprint class. Let the name be `Mutable<Protobuf name>` and annotate it with `@ImmutableProto(<Protobuf class>)` (`Protobuf class` is a reference to the generated (mutable) class):
```dart
import 'package:immutable_proto/immutable_proto.dart';
// Use an import prefix to avoid name conflicts:
import 'proto_generated/user.pb.dart' as proto;

part 'main.g.dart';

@ImmutableProto(proto.User)
class MutableUser {
  String firstName;

  @required // This field must not be null
  String lastName;

  // Lists are non-nullable by default
  List<String> emailAddresses;

  // Will be replaced by the generated enum
  proto.User_FavoriteDrink favoriteDrink;
}
```

5. Run `pub run build_runner build` in the command line (or `flutter pub run build_runner build`, if you're using Flutter). The implementation based on your blueprint class will automatically get generated.

The immutable class contains
- a constructor with named parameters and assertions for required values
- method/constructor for converting the immutable class to the mutable class (generated by Protocol Buffers) and the other way around
- custom implementations of `==`, `hashCode` and `toString()`
- a copy method
- enum mappers

For example, here's the generated code of our class above:
```dart
@immutable
class User {
  final String firstName;
  final String lastName;
  @required
  final List<String> emailAddresses;
  final UserFavoriteDrink favoriteDrink;

  User({
    this.firstName,
    this.lastName,
    @required this.emailAddresses,
    this.favoriteDrink,
  }) : assert(emailAddresses != null);

  User.fromProto(proto.User user)
      : this(
          firstName: user.firstName,
          lastName: user.lastName,
          emailAddresses: user.emailAddresses,
          favoriteDrink: userFavoriteDrinkFromProto(user.favoriteDrink),
        );
  proto.User toProto() {
    final user = proto.User();
    if (firstName != null) user.firstName = firstName;
    if (lastName != null) user.lastName = lastName;
    user.emailAddresses.addAll(emailAddresses);
    if (favoriteDrink != null)
      user.favoriteDrink = userFavoriteDrinkToProto(favoriteDrink);
    return user;
  }

  bool operator ==(Object other) {
    return other is User &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        emailAddresses == other.emailAddresses &&
        favoriteDrink == other.favoriteDrink;
  }

  int get hashCode => hashList([
        firstName,
        lastName,
        emailAddresses,
        favoriteDrink,
      ]);
  User copy({
    String firstName,
    String lastName,
    List<String> emailAddresses,
    UserFavoriteDrink favoriteDrink,
  }) =>
      User(
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        emailAddresses: emailAddresses ?? this.emailAddresses,
        favoriteDrink: favoriteDrink ?? this.favoriteDrink,
      );

  String toString() {
    return 'User(firstName: $firstName, lastName: $lastName, emailAddresses: $emailAddresses, favoriteDrink: $favoriteDrink)';
  }

  static UserFavoriteDrink userFavoriteDrinkFromProto(
      proto.User_FavoriteDrink userFavoriteDrink) {
    switch (userFavoriteDrink) {
      case proto.User_FavoriteDrink.COFFEE:
        return UserFavoriteDrink.coffee;
      case proto.User_FavoriteDrink.COKE:
        return UserFavoriteDrink.coke;
      case proto.User_FavoriteDrink.TEA:
        return UserFavoriteDrink.tea;
      case proto.User_FavoriteDrink.UNKNOWN:
      default:
        return UserFavoriteDrink.unknown;
    }
  }

  static proto.User_FavoriteDrink userFavoriteDrinkToProto(
      UserFavoriteDrink userFavoriteDrink) {
    switch (userFavoriteDrink) {
      case UserFavoriteDrink.coffee:
        return proto.User_FavoriteDrink.COFFEE;
      case UserFavoriteDrink.coke:
        return proto.User_FavoriteDrink.COKE;
      case UserFavoriteDrink.tea:
        return proto.User_FavoriteDrink.TEA;
      case UserFavoriteDrink.unknown:
      default:
        return proto.User_FavoriteDrink.UNKNOWN;
    }
  }
}

enum UserFavoriteDrink {
  unknown,
  coffee,
  coke,
  tea,
}
```

## Features

- [x] Generate basic immutable classes for a message
- [x] Generate classes for **nested messages** automatically
- [x] Generate enum + mappers for **nested enums** automatically
- [ ] Support built-in [wrappers](https://github.com/protocolbuffers/protobuf/blob/master/src/google/protobuf/wrappers.proto) (e.g. UInt32Value)
- [ ] `oneof`-support
- [ ] Commented code
- [ ] Custom methods
