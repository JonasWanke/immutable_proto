import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:immutable_proto/immutable_proto.dart';
import 'package:kt_dart/collection.dart';

import 'proto_enum.dart';
import 'proto_field.dart';
import 'utils.dart';

@immutable
class ProtoMessage {
  static const TYPE_PB_MESSAGE = 'GeneratedMessage';

  const ProtoMessage._(
    this.protoMessage,
    this.enums,
    this.fields, [
    this.annotatedClass,
  ])  : assert(protoMessage != null),
        assert(enums != null),
        assert(fields != null);

  static Future<ProtoMessage> create(
    ClassElement clazz, [
    ClassElement annotatedClass,
  ]) async {
    final enums = ProtoEnum.enumsForClass(clazz);
    return ProtoMessage._(
      clazz,
      enums,
      await ProtoField.fieldsForMessage(clazz, enums),
      annotatedClass,
    );
  }

  static Future<KtList<ProtoMessage>> subMessages(ProtoMessage message) async {
    assert(message != null);
    return Future.wait(message.protoMessage.library.topLevelElements
        .whereType<ClassElement>()
        .where((e) => e.name.startsWith(message.protoMessage.name))
        .where((e) => isTypeMessage(e.type))
        .map((e) => ProtoMessage.create(e))).then((m) => KtList.from(m));
  }

  static bool isTypeMessage(InterfaceType type) =>
      type.superclass.name == TYPE_PB_MESSAGE;

  final ClassElement protoMessage;
  final KtList<ProtoEnum> enums;
  final KtList<ProtoField> fields;

  final ClassElement annotatedClass;

  String get name => snakeCamelToUpperCamel(protoMessage.name);

  String generate() {
    final lowerName = lowerFirstChar(name);

    var extendsImplements = '';
    if (annotatedClass != null) {
      if (annotatedClass.supertype?.isObject == false)
        extendsImplements += ' extends ${annotatedClass.supertype.name} ';
      if (annotatedClass.interfaces.isNotEmpty)
        extendsImplements +=
            KtList.from(annotatedClass.interfaces).joinToString(
          transform: (i) => i.name,
          prefix: ' implements ',
        );
    }

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

    final enumDefinitions = enums.joinToString(
      transform: (e) => e.generateEnum(),
      separator: '\n\n',
    );
    final enumMappers = enums.joinToString(
      transform: (e) => e.generateMappers(),
      separator: '\n\n',
    );

    return '''
/*
@immutable
class $name $extendsImplements {
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

$enumDefinitions
*/
''';
  }
}
