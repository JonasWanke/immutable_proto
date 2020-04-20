import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:immutable_proto_generator/src/utils.dart';
import 'package:meta/meta.dart';

import 'proto_enum.dart';
import 'proto_message.dart';

@immutable
class ProtoField {
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
  ) async {
    final type = singleTypeOf(field.type);
    return ProtoField._(
      await field.library.typeSystem,
      protoMessage,
      field,
      protoFieldFor(protoMessage, field),
      await ProtoMessage.forProtoClass(type.element),
      ProtoEnum.forProtoClass(type.element),
    );
  }

  static Future<List<ProtoField>> fieldsForMessage(
    ClassElement protoMessage,
  ) async {
    return Future.wait(
      protoMessage.fields
          .where((f) => !f.isStatic)
          .where((f) => f.name != 'info_')
          .where((f) => !protoMessage.supertype.element.fields.contains(f))
          .map((f) => ProtoField.create(protoMessage, f)),
    );
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
  String get type => isList ? 'List<$singleType>' : singleType;

  static InterfaceType singleTypeOf(DartType type) {
    return (isTypeList(type) ? (type as InterfaceType).typeArguments[0] : type)
        as InterfaceType;
  }

  String get singleType {
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
  bool get isRequired => field.hasRequired || isList || isEnum;

  String generateField() =>
      (isRequired ? '@required ' : '') + 'final $type $name;';

  String generateCtorArg() => (isRequired ? '@required ' : '') + 'this.$name,';
  String generateCtorInitializer() =>
      isRequired ? 'assert($name != null)' : null;

  String generateFromProtoArg(String protoName) {
    final short = name[0];
    var res = '$protoName.$name';
    if (isList) {
      res = '$protoName.$name';
      if (isMessage) {
        res = '$res.map(($short) => ${protoMessage.name}.fromProto($short))';
      }
      if (isEnum) {
        res = '$res.map(($short) => ${protoEnum.fromProtoMethodName}($short))';
      }
    } else {
      if (isMessage) res = '${protoMessage.name}.fromProto($res)';
      if (isEnum) res = '${protoEnum.fromProtoMethodName}($res)';
      if (!isRequired) {
        res = '$protoName.has${upperFirstChar(name)}() ? $res : null';
      }
    }
    return '$name: $res';
  }

  String generateToProtoLine(String protoName) {
    final short = name[0];
    var res = '$name';
    if (isList) {
      if (isMessage) res = '$res.map(($short) => $short.toProto())';
      if (isEnum) {
        res = '$res.map(($short) => ${protoEnum.toProtoMethodName}($short))';
      }
      res = '$protoName.$name.addAll($res);';
    } else {
      if (isMessage) res = '$res.toProto()';
      if (isEnum) res = '${protoEnum.toProtoMethodName}($res)';
      res = '$protoName.$name = $res;';
    }
    return (isRequired ? '' : 'if ($name != null) ') + res;
  }

  String generateEquals(String otherName) => '$name == $otherName.$name';
  String generateCopyParam() => '$name: $name ?? this.$name,';
}
