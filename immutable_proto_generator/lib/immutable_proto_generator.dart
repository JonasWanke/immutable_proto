library immutable_proto_generator;

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:immutable_proto/immutable_proto.dart';
import 'package:immutable_proto_generator/src/proto_field.dart';
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
        e.fields.map((f) => ProtoField.create(type, f)),
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
/*
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
*/
''';
  }
}
