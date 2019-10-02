// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// ImmutableProtoGenerator
// **************************************************************************

@immutable
class User {
  final String firstName;
  final String lastName;
  @required
  final KtList<String> emailAddresses;
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
          emailAddresses: KtList.from(user.emailAddresses),
          favoriteDrink: userFavoriteDrinkFromProto(user.favoriteDrink),
        );
  proto.User toProto() {
    final user = proto.User();
    if (firstName != null) user.firstName = firstName;
    if (lastName != null) user.lastName = lastName;
    user.emailAddresses.addAll(emailAddresses.iter);
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
    KtList<String> emailAddresses,
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
