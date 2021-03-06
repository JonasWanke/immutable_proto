import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dartx/dartx.dart';
import 'package:meta/meta.dart';

import 'proto_enum.dart';
import 'proto_field.dart';
import 'utils.dart';

@immutable
class ProtoMessage {
  static const TYPE_PB_MESSAGE = 'GeneratedMessage';

  static final Map<ClassElement, ProtoMessage> _messages = {};

  const ProtoMessage._(
    this.protoMessage,
    this.subMessages,
    this.enums,
    this.fields, {
    this.annotatedClass,
  })  : assert(protoMessage != null),
        assert(enums != null),
        assert(fields != null);

  static Future<ProtoMessage> forProtoClass(
    ClassElement protoClass, {
    ClassElement annotatedClass,
    List<ProtoMessage> subMessages,
  }) async {
    assert(protoClass != null);
    if (!isTypeMessage(protoClass.thisType)) return null;

    if (_messages[protoClass] != null) return _messages[protoClass];

    final enums = ProtoEnum.enumsForClass(protoClass);
    final subMessages = await _subMessages(protoClass);
    return _messages[protoClass] = ProtoMessage._(
      protoClass,
      subMessages,
      enums,
      await ProtoField.fieldsForMessage(protoClass),
      annotatedClass: annotatedClass,
    );
  }

  static Future<List<ProtoMessage>> _subMessages(
    ClassElement protoClass,
  ) async {
    assert(protoClass != null);

    return Future.wait(
      protoClass.library.topLevelElements
          .whereType<ClassElement>()
          .where((e) => isTypeMessage(e.thisType))
          .where((e) => isDirectlyNestedPbClass(protoClass, e))
          .map((e) => ProtoMessage.forProtoClass(e)),
    );
  }

  static bool isTypeMessage(InterfaceType type) =>
      type.superclass.name == TYPE_PB_MESSAGE;

  final ClassElement protoMessage;
  final List<ProtoEnum> enums;
  final List<ProtoField> fields;

  final ClassElement annotatedClass;
  final List<ProtoMessage> subMessages;

  String get name => snakeCamelToUpperCamel(protoMessage.name);
  String get protoName => protoMessage.name;

  String generate() {
    final lowerName = lowerFirstChar(name);

    var extendsImplements = '';
    if (annotatedClass != null) {
      if (annotatedClass.supertype?.isObject == false) {
        extendsImplements += ' extends ${annotatedClass.supertype.name} ';
      }
      if (annotatedClass.interfaces.isNotEmpty) {
        extendsImplements += ' implements ';
        extendsImplements +=
            annotatedClass.interfaces.joinToString(transform: (i) => i.name);
      }
    }

    final classFields = fields.joinToString(
      transform: (f) => f.generateField(),
      separator: '\n',
    );

    final ctorArgs = fields.joinToString(
      transform: (f) => f.generateCtorArg(),
      separator: '\n',
    );
    final ctorInitializersList =
        fields.mapNotNull((f) => f.generateCtorInitializer()).joinToString();
    final ctorInitializers =
        (ctorInitializersList.isNotEmpty ? ':' : '') + ctorInitializersList;

    final fromProtoFields = fields.joinToString(
      transform: (f) => f.generateFromProtoArg(lowerName),
      separator: '',
      postfix: ',',
    );
    final toProtoFields = fields.joinToString(
      transform: (f) => f.generateToProtoLine(lowerName),
      separator: '\n',
    );

    final equalsExpression = fields.joinToString(
      transform: (f) => f.generateEquals('other'),
      prefix: ' && ',
      separator: '',
    );
    final hashList = fields.joinToString(
      transform: (f) => f.name,
      separator: '',
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
    final toString =
        '\'$name(${fields.joinToString(transform: (f) => '${f.name}: \$${f.name}')})\'';

    final enumDefinitions = enums.joinToString(
      transform: (e) => e.generateEnum(),
      separator: '\n\n',
    );
    final enumMappers = enums.joinToString(
      transform: (e) => e.generateMappers(),
      separator: '\n\n',
    );

    final subMessagesCode = subMessages?.joinToString(
          transform: (m) => m.generate(),
          separator: '\n\n',
        ) ??
        '';

    return '''
@immutable
class $name $extendsImplements {
  $classFields

  $name({
    $ctorArgs
  }) $ctorInitializers;

  $name.fromProto(proto.$protoName $lowerName)
    : this($fromProtoFields);
  proto.$protoName toProto() {
    final $lowerName = proto.$protoName();
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

$subMessagesCode
''';
  }
}
