///
//  Generated code. Do not modify.
//  source: user.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

// ignore_for_file: UNDEFINED_SHOWN_NAME,UNUSED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class User_FavoriteDrink extends $pb.ProtobufEnum {
  static const User_FavoriteDrink UNKNOWN = User_FavoriteDrink._(0, 'UNKNOWN');
  static const User_FavoriteDrink COFFEE = User_FavoriteDrink._(1, 'COFFEE');
  static const User_FavoriteDrink COKE = User_FavoriteDrink._(2, 'COKE');
  static const User_FavoriteDrink TEA = User_FavoriteDrink._(3, 'TEA');

  static const $core.List<User_FavoriteDrink> values = <User_FavoriteDrink> [
    UNKNOWN,
    COFFEE,
    COKE,
    TEA,
  ];

  static final $core.Map<$core.int, User_FavoriteDrink> _byValue = $pb.ProtobufEnum.initByValue(values);
  static User_FavoriteDrink valueOf($core.int value) => _byValue[value];

  const User_FavoriteDrink._($core.int v, $core.String n) : super(v, n);
}

