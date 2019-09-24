///
//  Generated code. Do not modify.
//  source: user.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core show bool, Deprecated, double, int, List, Map, override, pragma, String;

import 'package:protobuf/protobuf.dart' as $pb;

import 'user.pbenum.dart';

export 'user.pbenum.dart';

class User_EmailAddress extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('User.EmailAddress', package: const $pb.PackageName('wanke.immutable_proto.example'))
    ..aOS(1, 'localPart')
    ..aOS(2, 'domain')
    ..hasRequiredFields = false
  ;

  User_EmailAddress._() : super();
  factory User_EmailAddress() => create();
  factory User_EmailAddress.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory User_EmailAddress.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  User_EmailAddress clone() => User_EmailAddress()..mergeFromMessage(this);
  User_EmailAddress copyWith(void Function(User_EmailAddress) updates) => super.copyWith((message) => updates(message as User_EmailAddress));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static User_EmailAddress create() => User_EmailAddress._();
  User_EmailAddress createEmptyInstance() => create();
  static $pb.PbList<User_EmailAddress> createRepeated() => $pb.PbList<User_EmailAddress>();
  static User_EmailAddress getDefault() => _defaultInstance ??= create()..freeze();
  static User_EmailAddress _defaultInstance;

  $core.String get localPart => $_getS(0, '');
  set localPart($core.String v) { $_setString(0, v); }
  $core.bool hasLocalPart() => $_has(0);
  void clearLocalPart() => clearField(1);

  $core.String get domain => $_getS(1, '');
  set domain($core.String v) { $_setString(1, v); }
  $core.bool hasDomain() => $_has(1);
  void clearDomain() => clearField(2);
}

class User extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('User', package: const $pb.PackageName('wanke.immutable_proto.example'))
    ..aOS(1, 'firstName')
    ..aOS(2, 'lastName')
    ..pc<User_EmailAddress>(3, 'emailAddresses', $pb.PbFieldType.PM,User_EmailAddress.create)
    ..pc<User_FavoriteDrink>(4, 'favoriteDrinks', $pb.PbFieldType.PE, null, User_FavoriteDrink.valueOf, User_FavoriteDrink.values)
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
  static User getDefault() => _defaultInstance ??= create()..freeze();
  static User _defaultInstance;

  $core.String get firstName => $_getS(0, '');
  set firstName($core.String v) { $_setString(0, v); }
  $core.bool hasFirstName() => $_has(0);
  void clearFirstName() => clearField(1);

  $core.String get lastName => $_getS(1, '');
  set lastName($core.String v) { $_setString(1, v); }
  $core.bool hasLastName() => $_has(1);
  void clearLastName() => clearField(2);

  $core.List<User_EmailAddress> get emailAddresses => $_getList(2);

  $core.List<User_FavoriteDrink> get favoriteDrinks => $_getList(3);
}

