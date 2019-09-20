library immutable_proto_generator;

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:build/build.dart';
import 'package:immutable_proto/immutable_proto.dart';
import 'package:immutable_proto_generator/src/utils.dart';
import 'package:kt_dart/collection.dart';
import 'package:source_gen/source_gen.dart';

Builder generateImmutableProto(BuilderOptions options) =>
    SharedPartBuilder([ImmutableProtoGenerator()], 'immutable_proto');

@immutable
class ImmutableProtoGenerator extends Generator {
  static const String MUTABLE_PREFIX = 'Mutable';

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final values = KtMutableSet<String>.empty();

    for (var annotatedElement
        in library.annotatedWith(TypeChecker.fromRuntime(ImmutableProto))) {
      values.add(await generateForAnnotatedElement(
          annotatedElement.element, annotatedElement.annotation, buildStep));
    }

    return values.joinToString(separator: '\n\n');
  }

  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    assert(element is ClassElement,
        'Only classes can be annotated with `@ImmutableProto()`.');
    assert(
        element.name.startsWith(MUTABLE_PREFIX),
        'The names of classes annotated with `@ImmutableProto()` should start '
        'with `$MUTABLE_PREFIX`, for example `${MUTABLE_PREFIX}User`. The '
        'immutable class will then get automatically generated for you by '
        'running `pub run build_runner build` (or '
        '`flutter pub run build_runner build` if you\'re on Flutter).');

    final e = element as ClassElement;
    final name = e.name.substring(MUTABLE_PREFIX.length);
    final lowerName = lowerFirstChar(name);
    final type = annotation.read('type').typeValue;
    final fields = KtList.from(
      await Future.wait(
        e.fields.map((f) => _ProtoField.create(type, f)),
      ),
    );

    final classFields = fields.joinToString(
      transform: (f) => f.generateField(),
      separator: '\n',
    );

    final ctorArgs = fields.joinToString(
      transform: (f) => f.generateCtorArg(),
      separator: '\n',
    );
    final ctorInitializers = fields
        .mapNotNull((f) => f.generateCtorInitializer())
        .joinToString(prefix: ':');

    final fromProtoFields = fields.joinToString(
      transform: (f) => f.generateFromProtoArg(lowerName),
      postfix: ',',
    );
    final toProtoFields = fields.joinToString(
      transform: (f) => f.generateToProtoLine(lowerName),
      separator: '\n',
    );

    final equalsExpression = fields.joinToString(
      transform: (f) => f.generateEquals('other'),
      prefix: '&& ',
      separator: ' && ',
    );
    final hashList = fields.joinToString(
      transform: (f) => f.name,
      postfix: ',',
    );
    final copyArgs = fields.joinToString(
      transform: (f) => '${f.type} ${f.name},',
      separator: '\n',
    );
    final copyParams = fields.joinToString(
      transform: (f) => f.generateCopyParam(),
      separator: '\n',
    );
    final toString = fields.joinToString(
      prefix: '\'$name(',
      transform: (f) => '${f.name}: \$${f.name}',
      postfix: ')\'',
    );

    final enums = fields
        .mapNotNull((f) => f.generateEnum())
        .joinToString(separator: '\n\n');
    final enumMappers = fields
        .mapNotNull((f) => f.generateEnumMappers())
        .joinToString(separator: '\n\n');

    return '''
@immutable
class $name${e.supertype != null ? ' extends ' + e.supertype.toString() : ''} {
  $classFields

  $name({
    $ctorArgs
  }) $ctorInitializers;

  $name.fromProto(proto.$name $lowerName)
    : this($fromProtoFields);
  proto.$name toProto() {
    final $lowerName = proto.$name();
    $toProtoFields
    return $lowerName;
  }

  bool operator ==(Object other) {
    return other is $name $equalsExpression;
  }
  int get hashCode => hashList([
    $hashList
  ]);
  $name copy({
    $copyArgs
  }) =>
      $name(
        $copyParams
      );

  String toString() {
    return $toString;
  }


  $enumMappers
}

$enums
''';
  }
}

class _ProtoField {
  static const TYPE_LIST = 'KtList';
  static const KNOWN_LIST_TYPES = ['List', TYPE_LIST, 'KtMutableList'];
  static const TYPE_PB_ENUM = 'ProtobufEnum';

  _ProtoField(this.typeSystem, this.protoType, this.field, this.protoField)
      : assert(typeSystem != null),
        assert(protoType != null),
        assert(field != null),
        assert(protoField != null);

  static Future<_ProtoField> create(
      DartType protoType, FieldElement field) async {
    final visitor = FieldGetterVisitor(field.name);
    protoType.element.visitChildren(visitor);

    return _ProtoField(
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
