library immutable_proto_generator;

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:immutable_proto/immutable_proto.dart';
import 'package:kt_dart/collection.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'src/proto_message.dart';

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

    return values.filterNotNull().joinToString(separator: '\n\n');
  }

  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element is! ClassElement)
      throw 'Only classes can be annotated with `@ImmutableProto()`.';
    if (!element.name.startsWith(MUTABLE_PREFIX))
      throw 'The names of classes annotated with `@ImmutableProto()` should '
          'start with `$MUTABLE_PREFIX`, for example `${MUTABLE_PREFIX}User`. '
          'The immutable class will then get automatically generated for you '
          'by running `pub run build_runner build` (or '
          '`flutter pub run build_runner build` if you\'re on Flutter).';

    final protoMessage =
        annotation.read('type').typeValue.element as ClassElement;
    final annotatedElement = element as ClassElement;

    final message = await ProtoMessage.forProtoClass(
      protoMessage,
      annotatedClass: annotatedElement,
    );
    return message.generate();
  }
}
