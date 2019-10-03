///
//  Generated code. Do not modify.
//  source: lib/user.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'user.pbenum.dart';

export 'user.pbenum.dart';

class User extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('User', package: const $pb.PackageName('wanke.immutable_proto.example'), createEmptyInstance: create)
    ..aOS(1, 'firstName')
    ..aOS(2, 'lastName')
    ..pPS(3, 'emailAddresses')
    ..e<User_FavoriteDrink>(4, 'favoriteDrink', $pb.PbFieldType.OE, defaultOrMaker: User_FavoriteDrink.UNKNOWN, valueOf: User_FavoriteDrink.valueOf, enumValues: User_FavoriteDrink.values)
    ..hasRequiredFields = false
  ;

  User._() : super();
  factory User() => create();
  factory User.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory User.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  User clone() => User()..mergeFromMessage(this);
  User copyWith(void Function(User) updates) => super.copyWith((message) => updates(message as User));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static User create() => User._();
  User createEmptyInstance() => create();
  static $pb.PbList<User> createRepeated() => $pb.PbList<User>();
  @$core.pragma('dart2js:noInline')
  static User getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<User>(create);
  static User _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get firstName => $_getSZ(0);
  @$pb.TagNumber(1)
  set firstName($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFirstName() => $_has(0);
  @$pb.TagNumber(1)
  void clearFirstName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get lastName => $_getSZ(1);
  @$pb.TagNumber(2)
  set lastName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLastName() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastName() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.String> get emailAddresses => $_getList(2);

  @$pb.TagNumber(4)
  User_FavoriteDrink get favoriteDrink => $_getN(3);
  @$pb.TagNumber(4)
  set favoriteDrink(User_FavoriteDrink v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasFavoriteDrink() => $_has(3);
  @$pb.TagNumber(4)
  void clearFavoriteDrink() => clearField(4);
}

