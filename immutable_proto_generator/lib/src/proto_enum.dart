import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartx/dartx.dart';
import 'package:meta/meta.dart';

import 'utils.dart';

@immutable
class ProtoEnum {
  static const TYPE_PB_ENUM = 'ProtobufEnum';

  static final Map<ClassElement, ProtoEnum> _enums = {};

  const ProtoEnum._(this.protoClass) : assert(protoClass != null);

  factory ProtoEnum.forProtoClass(ClassElement protoClass) {
    assert(protoClass != null);
    if (!isTypeEnum(protoClass.thisType)) return null;

    if (_enums[protoClass] != null) return _enums[protoClass];

    return _enums[protoClass] = ProtoEnum._(protoClass);
  }

  static List<ProtoEnum> enumsForClass(ClassElement protoMessageClass) {
    assert(protoMessageClass != null);
    return [
      ...protoMessageClass.library.exports.map((e) => e.exportedLibrary),
      protoMessageClass.library,
    ]
        .flatMap((l) => l.topLevelElements)
        .whereType<ClassElement>()
        .where((e) => isTypeEnum(e.thisType))
        .where((e) => isDirectlyNestedPbClass(protoMessageClass, e))
        .map((e) => ProtoEnum.forProtoClass(e))
        .toList();
  }

  static bool isTypeEnum(InterfaceType type) =>
      type.superclass.name == TYPE_PB_ENUM;

  final ClassElement protoClass;

  String get name => snakeCamelToUpperCamel(protoClass.name);
  bool get isTopLevel => !protoClass.name.contains('_');

  String get fromProtoMethodName => '${lowerFirstChar(name)}FromProto';
  String get toProtoMethodName => '${lowerFirstChar(name)}ToProto';

  Iterable<String> protoValues() => protoClass.fields
      .filter((f) => f.type == protoClass.thisType)
      .map((f) => f.name)
      .toList();

  String generateEnum() {
    final values = protoValues().joinToString(
      transform: (v) => '${snakeToLowerCamel(v)},',
      separator: '\n',
    );
    return '''
enum $name {
  $values
}
''';
  }

  String generateMappers() {
    final protoName = protoClass.name;
    final argName = lowerFirstChar(name);
    final protoValues = this.protoValues();

    final modifier = isTopLevel ? '' : 'static';
    final fromCases = [
      for (final value in protoValues.skip(1))
        'case proto.$protoName.$value:'
            '  return $name.${snakeToLowerCamel(value)};',
      'case proto.$protoName.${protoValues.first}:'
          'default:'
          '  return $name.${snakeToLowerCamel(protoValues.first)};',
    ].joinToString(separator: '\n');
    final toCases = [
      for (final value in protoValues.skip(1))
        'case $name.${snakeToLowerCamel(value)}:'
            '  return proto.$protoName.$value;',
      'case $name.${snakeToLowerCamel(protoValues.first)}:'
          'default:'
          '  return proto.$protoName.${protoValues.first};',
    ].joinToString(separator: '\n');

    return '''
$modifier $name $fromProtoMethodName(proto.$protoName $argName) {
  switch ($argName) {
    $fromCases
  }
}

$modifier proto.$protoName $toProtoMethodName($name $argName) {
  switch ($argName) {
    $toCases
  }
}
''';
  }
}
