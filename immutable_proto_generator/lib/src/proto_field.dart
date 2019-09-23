import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:immutable_proto/immutable_proto.dart';
import 'package:immutable_proto_generator/src/utils.dart';
import 'package:kt_dart/collection.dart';

import 'enum_generator.dart';

@immutable
class ProtoField {
  static const TYPE_LIST = 'KtList';

  const ProtoField._(
    this.typeSystem,
    this.protoMessage,
    this.field,
    this.protoField, [
    this.protoEnum,
  ])  : assert(typeSystem != null),
        assert(protoMessage != null),
        assert(field != null),
        assert(protoField != null);

  static Future<ProtoField> create(
    ClassElement protoMessage,
    FieldElement field,
    KtList<ProtoEnum> knownEnums,
  ) async {
    if (isTypeList(field.type) && field.type.name != TYPE_LIST)
      throw 'Only $TYPE_LIST should be used as a list type but '
          '${field.enclosingElement.name}.{field.name} has type ${field.type}';
    return ProtoField._(
      await field.session.typeSystem,
      protoMessage,
      field,
      protoFieldFor(protoMessage, field),
    );
  }

  static FieldElement protoFieldFor(
    ClassElement protoMessage,
    FieldElement field,
  ) {
    return protoMessage.fields.firstWhere((f) => f.name == field.name);
  }

  final TypeSystem typeSystem;
  final ClassElement protoMessage;
  final FieldElement protoField;
  final ProtoEnum protoEnum;

  final FieldElement field;
  String get type => isList ? '$TYPE_LIST<$singleType>' : singleType;

  static InterfaceType singleTypeOf(DartType type) {
    return (isTypeList(type) ? (type as InterfaceType).typeArguments[0] : type)
        as InterfaceType;
  }

  String get singleType {
    if (isEnum) return protoEnum.name;
    return isList
        ? (field.type as InterfaceType).typeArguments[0].name
        : protoField.type.name;
  }

  String get name => field.name;

  bool get isList => isTypeList(field.type);
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
      if (isEnum)
        res = '$res.map(($short) => ${protoEnum.fromProtoMethodName}($short))';
    } else if (isEnum) res = '${protoEnum.fromProtoMethodName}($res)';
    return '$name: $res';
  }

  String generateToProtoLine(String protoName) {
    final short = name[0];
    var res = '$name';
    if (isList) {
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
