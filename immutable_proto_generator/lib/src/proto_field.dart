import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:immutable_proto_generator/src/utils.dart';
import 'package:kt_dart/collection.dart';

class ProtoField {
  static const TYPE_LIST = 'KtList';
  static const KNOWN_LIST_TYPES = ['List', TYPE_LIST, 'KtMutableList'];
  static const TYPE_PB_ENUM = 'ProtobufEnum';

  ProtoField(this.typeSystem, this.protoType, this.field, this.protoField)
      : assert(typeSystem != null),
        assert(protoType != null),
        assert(field != null),
        assert(protoField != null);

  static Future<ProtoField> create(
      DartType protoType, FieldElement field) async {
    final visitor = FieldGetterVisitor(field.name);
    protoType.element.visitChildren(visitor);

    return ProtoField(
      await field.session.typeSystem,
      protoType,
      field,
      visitor.field,
    );
  }

  final TypeSystem typeSystem;
  final DartType protoType;
  final FieldElement protoField;

  final FieldElement field;
  String get type {
    if (isList) {
      if (isEnum) return '$TYPE_LIST<$enumName>';
      return '$TYPE_LIST<${(field.type as InterfaceType).typeArguments[0]}>';
    } else {
      if (isEnum) return enumName;
      return field.type.name;
    }
  }

  String get name => field.name;

  bool get isList => KNOWN_LIST_TYPES.contains(field.type.name);
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
      if (isEnum) res = '$res.map(($short) => $enumFromProtoName($short))';
    } else if (isEnum) res = '$enumFromProtoName($res)';
    return '$name: $res';
  }

  String generateToProtoLine(String protoName) {
    final short = name[0];
    var res = '$name';
    if (isList) {
      if (isEnum) res = '$res.map(($short) => $enumToProtoName($short))';
      res = '$protoName.$name.addAll($res.iter);';
    } else {
      if (isEnum) res = '$enumToProtoName($res)';
      res = '$protoName.$name = $res;';
    }
    return (isRequired ? '' : 'if ($name != null) ') + res;
  }

  String generateEquals(String otherName) => '$name == $otherName.$name';
  String generateCopyParam() => '$name: $name ?? this.$name,';

  bool get isEnum => enumProtoClass != null;

  ClassElement get enumProtoClass {
    final type = isList
        ? (field.type as InterfaceType).typeArguments[0]
        : protoField.type;
    assert(type is InterfaceType, 'Unknown type of field $field: $type');
    if ((type as InterfaceType).superclass.name != TYPE_PB_ENUM) return null;
    return type.element as ClassElement;
  }

  String get enumName {
    final clazz = enumProtoClass;
    if (clazz == null) return null;
    return snakeCamelToUpperCamel(clazz?.name);
  }

  String get enumFromProtoName => '${lowerFirstChar(enumName)}FromProto';
  String get enumToProtoName => '${lowerFirstChar(enumName)}ToProto';

  KtList<String> enumValuesProto() {
    print('enumValuesProto: $enumProtoClass');
    return KtList.from(enumProtoClass.fields)
        .filter((f) => f.type == enumProtoClass.type)
        .map((f) => f.name);
  }

  String generateEnum() {
    if (!isEnum) return null;

    final values = enumValuesProto().joinToString(
      transform: (v) => '${snakeToLowerCamel(v)},',
      separator: '\n',
    );
    return '''
enum $enumName {
  $values
}
''';
  }

  String generateEnumMappers() {
    if (!isEnum) return null;

    final protoName = enumProtoClass.name;
    final argName = lowerFirstChar(enumName);

    final protoValues = enumValuesProto();
    final fromCases = protoValues
        .drop(1)
        .map((f) => 'case proto.$protoName.$f:'
            '  return $enumName.${snakeToLowerCamel(f)};')
        .plusElement('case proto.$protoName.${protoValues.first()}:'
            'default:'
            '  return $enumName.${snakeToLowerCamel(protoValues.first())};')
        .joinToString(separator: '\n');
    final toCases = protoValues
        .drop(1)
        .map((f) => 'case $enumName.${snakeToLowerCamel(f)}:'
            '  return proto.$protoName.$f;')
        .plusElement('case $enumName.${snakeToLowerCamel(protoValues.first())}:'
            'default:'
            '  return proto.$protoName.${protoValues.first()};')
        .joinToString(separator: '\n');

    return '''
static $enumName $enumFromProtoName(proto.$protoName $argName) {
  switch ($argName) {
    $fromCases
  }
}

static proto.$protoName $enumToProtoName($enumName $argName) {
  switch ($argName) {
    $toCases
  }
}
''';
  }
}
