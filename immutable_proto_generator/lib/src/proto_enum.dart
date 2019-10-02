import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:immutable_proto/immutable_proto.dart';

import 'utils.dart';

@immutable
class ProtoEnum {
  static const TYPE_PB_ENUM = 'ProtobufEnum';

  const ProtoEnum(this.protoClass) : assert(protoClass != null);

  static KtList<ProtoEnum> enumsForClass(ClassElement protoMessageClass) {
    assert(protoMessageClass != null);
    return KtList.from(protoMessageClass.library.exports)
        .map((e) => e.exportedLibrary)
        .plusElement(protoMessageClass.library)
        .flatMap((l) => KtList.from(l.topLevelElements))
        .filterIsInstance<ClassElement>()
        .filter((e) => isTypeEnum(e.type))
        .filter((e) => e.name.startsWith(protoMessageClass.name))
        .map((e) => ProtoEnum(e));
  }

  static bool isTypeEnum(InterfaceType type) =>
      type.superclass.name == TYPE_PB_ENUM;

  final ClassElement protoClass;

  String get name => snakeCamelToUpperCamel(protoClass.name);
  bool get isTopLevel => !protoClass.name.contains('_');

  String get fromProtoMethodName => '${lowerFirstChar(name)}FromProto';
  String get toProtoMethodName => '${lowerFirstChar(name)}ToProto';

  KtList<String> protoValues() => KtList.from(protoClass.fields)
      .filter((f) => f.type == protoClass.type)
      .map((f) => f.name);

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
    final fromCases = protoValues
        .drop(1)
        .map((f) => 'case proto.$protoName.$f:'
            '  return $name.${snakeToLowerCamel(f)};')
        .plusElement('case proto.$protoName.${protoValues.first()}:'
            'default:'
            '  return $name.${snakeToLowerCamel(protoValues.first())};')
        .joinToString(separator: '\n');
    final toCases = protoValues
        .drop(1)
        .map((f) => 'case $name.${snakeToLowerCamel(f)}:'
            '  return proto.$protoName.$f;')
        .plusElement('case $name.${snakeToLowerCamel(protoValues.first())}:'
            'default:'
            '  return proto.$protoName.${protoValues.first()};')
        .joinToString(separator: '\n');

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
