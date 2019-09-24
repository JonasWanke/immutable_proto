import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:immutable_proto/immutable_proto.dart';
import 'package:immutable_proto_generator/src/utils.dart';
import 'package:kt_dart/collection.dart';

import 'proto_enum.dart';
import 'proto_message.dart';

@immutable
class ProtoField {
  static const TYPE_LIST = 'KtList';

  const ProtoField._(
    this.typeSystem,
    this.parentProtoMessage,
    this.field,
    this.protoField, [
    this.protoMessage,
    this.protoEnum,
  ])  : assert(typeSystem != null),
        assert(parentProtoMessage != null),
        assert(field != null),
        assert(protoField != null);

  static Future<ProtoField> create(
    ClassElement protoMessage,
    FieldElement field,
    KtList<ProtoMessage> knownMessages,
    KtList<ProtoEnum> knownEnums,
  ) async {
    // print('create: ${field.name}, ');
    return ProtoField._(
      await field.session.typeSystem,
      protoMessage,
      field,
      protoFieldFor(protoMessage, field),
      knownMessages
          .firstOrNull((e) => singleTypeOf(field.type) == e.protoMessage.type),
      knownEnums
          .firstOrNull((e) => singleTypeOf(field.type) == e.protoClass.type),
    );
  }

  static Future<KtList<ProtoField>> fieldsForMessage(
    ClassElement protoMessage,
    KtList<ProtoMessage> knownMessages,
    KtList<ProtoEnum> knownEnums,
  ) async {
    return Future.wait(protoMessage.fields
        .where((f) => !f.isStatic)
        .where((f) => f.name != 'info_')
        .where((f) => !protoMessage.supertype.element.fields.contains(f))
        .map(
          (f) => ProtoField.create(protoMessage, f, knownMessages, knownEnums),
        )).then((f) => KtList.from(f));
  }

  static FieldElement protoFieldFor(
    ClassElement protoMessage,
    FieldElement field,
  ) {
    return protoMessage.fields.firstWhere((f) => f.name == field.name);
  }

  final TypeSystem typeSystem;
  final ClassElement parentProtoMessage;
  final FieldElement protoField;
  final ProtoMessage protoMessage;
  final ProtoEnum protoEnum;

  final FieldElement field;
  String get type => isList ? '$TYPE_LIST<$singleType>' : singleType;

  static InterfaceType singleTypeOf(DartType type) {
    return (isTypeList(type) ? (type as InterfaceType).typeArguments[0] : type)
        as InterfaceType;
  }

  String get singleType {
    print('singleType: $name, $isEnum, $isList');
    if (isMessage) return protoMessage.name;
    if (isEnum) return protoEnum.name;
    return isList
        ? (field.type as InterfaceType).typeArguments[0].name
        : protoField.type.name;
  }

  String get name => field.name;

  bool get isList => isTypeList(field.type);
  bool get isMessage => protoMessage != null;
  bool get isEnum => protoEnum != null;
  bool get isRequired => field.hasRequired || isList;

  String generateField() =>
      (isRequired ? '@required ' : '') + 'final $type $name;';

  String generateCtorArg() => (isRequired ? '@required ' : '') + 'this.$name,';
  String generateCtorInitializer() =>
      isRequired ? 'assert($name != null)' : null;

  String generateFromProtoArg(String protoName) {
    final short = name[0];
    var res = '$protoName.$name';
    if (isList) {
      res = 'KtList.from($protoName.$name)';
      if (isMessage)
        res = '$res.map(($short) => ${protoMessage.name}.fromProto($short))';
      if (isEnum)
        res = '$res.map(($short) => ${protoEnum.fromProtoMethodName}($short))';
    } else if (isEnum) res = '${protoEnum.fromProtoMethodName}($res)';
    return '$name: $res';
  }

  String generateToProtoLine(String protoName) {
    final short = name[0];
    var res = '$name';
    if (isList) {
      if (isMessage) res = '$res.map(($short) => $short.toProto())';
      if (isEnum)
        res = '$res.map(($short) => ${protoEnum.toProtoMethodName}($short))';
      res = '$protoName.$name.addAll($res.iter);';
    } else {
      if (isEnum) res = '${protoEnum.toProtoMethodName}($res)';
      res = '$protoName.$name = $res;';
    }
    return (isRequired ? '' : 'if ($name != null) ') + res;
  }

  String generateEquals(String otherName) => '$name == $otherName.$name';
  String generateCopyParam() => '$name: $name ?? this.$name,';
}
