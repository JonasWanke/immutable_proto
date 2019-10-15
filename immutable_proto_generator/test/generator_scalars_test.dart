import 'dart:async';
import 'dart:mirrors';

import 'package:fixnum/fixnum.dart';
import 'package:immutable_proto/immutable_proto.dart';
import 'package:kt_dart/collection.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

import 'proto_generated/test_messages.pb.dart' as proto;

part 'generator_scalars_test.g.dart';

@ImmutableProto(proto.ScalarsMessage)
class MutableScalarsMessage {}

Future<void> main() async {
  group('ScalarsMessage', () {
    final messageWithNullsBuilder = () => ScalarsMessage(
          double_1: null,
          float: null,
          int32: null,
          int64: null,
          uint32: null,
          uint64: null,
          sint32: null,
          sint64: null,
          fixed32: null,
          fixed64: null,
          sfixed32: null,
          sfixed64: null,
          bool_13: null,
          string: null,
          bytes: KtList.empty(),
        );
    final messageWithZerosBuilder = () => ScalarsMessage(
          double_1: 0.0,
          float: 0.0,
          int32: 0,
          int64: Int64(0),
          uint32: 0,
          uint64: Int64(0),
          sint32: 0,
          sint64: Int64(0),
          fixed32: 0,
          fixed64: Int64(0),
          sfixed32: 0,
          sfixed64: Int64(0),
          bool_13: false,
          string: '',
          bytes: KtList.empty(),
        );

    group('.fromProto', () {
      test('works with null values', () {
        expect(messageWithNullsBuilder, returnsNormally);
      });
      test('crashes with null bytes', () {
        expect(() => ScalarsMessage(bytes: null),
            throwsA(TypeMatcher<AssertionError>()));
      });
      test('works with zero values', () {
        expect(messageWithZerosBuilder, returnsNormally);
      });
    });
    group('.toProto', () {
      group('with null values', () {
        test('returns normally', () {
          expect(() => messageWithNullsBuilder().toProto(), returnsNormally);
        });
        test('generates correct protobuf', () {
          expect(
              messageWithNullsBuilder().toProto(),
              isA<proto.ScalarsMessage>()
                  .having((m) => m.hasDouble_1(), 'double', isFalse)
                  .having((m) => m.hasFloat(), 'float', isFalse)
                  .having((m) => m.hasInt32(), 'int32', isFalse)
                  .having((m) => m.hasInt64(), 'int64', isFalse)
                  .having((m) => m.hasUint32(), 'uint32', isFalse)
                  .having((m) => m.hasUint64(), 'uint64', isFalse)
                  .having((m) => m.hasSint32(), 'sint32', isFalse)
                  .having((m) => m.hasSint64(), 'sint64', isFalse)
                  .having((m) => m.hasFixed32(), 'fixed32', isFalse)
                  .having((m) => m.hasFixed64(), 'fixed64', isFalse)
                  .having((m) => m.hasSfixed32(), 'sfixed32', isFalse)
                  .having((m) => m.hasSfixed64(), 'sfixed64', isFalse)
                  .having((m) => m.hasBool_13(), 'bool_13', isFalse)
                  .having((m) => m.hasString(), 'string', isFalse)
                  .having((m) => m.hasBytes(), 'bytes', isFalse));
        });
      });
      group('with zero values', () {
        test('returns normally', () {
          expect(() => messageWithZerosBuilder().toProto(), returnsNormally);
        });
        test('generates correct protobuf', () {
          expect(
              messageWithZerosBuilder().toProto(),
              isA<proto.ScalarsMessage>()
                  .having((m) => m.hasDouble_1(), 'double', isTrue)
                  .having((m) => m.hasFloat(), 'float', isTrue)
                  .having((m) => m.hasInt32(), 'int32', isTrue)
                  .having((m) => m.hasInt64(), 'int64', isTrue)
                  .having((m) => m.hasUint32(), 'uint32', isTrue)
                  .having((m) => m.hasUint64(), 'uint64', isTrue)
                  .having((m) => m.hasSint32(), 'sint32', isTrue)
                  .having((m) => m.hasSint64(), 'sint64', isTrue)
                  .having((m) => m.hasFixed32(), 'fixed32', isTrue)
                  .having((m) => m.hasFixed64(), 'fixed64', isTrue)
                  .having((m) => m.hasSfixed32(), 'sfixed32', isTrue)
                  .having((m) => m.hasSfixed64(), 'sfixed64', isTrue)
                  .having((m) => m.hasBool_13(), 'bool_13', isTrue)
                  .having((m) => m.hasString(), 'string', isTrue)
                  .having((m) => m.hasBytes(), 'bytes', isFalse));
        });
      });
    });

    group('has correct generated field types:', () {
      const types = {
        #double_1: double,
        #float: double,
        #int32: int,
        #int64: Int64,
        #uint32: int,
        #uint64: Int64,
        #sint32: int,
        #sint64: Int64,
        #fixed32: int,
        #fixed64: Int64,
        #sfixed32: int,
        #sfixed64: Int64,
        #bool_13: bool,
        #string: String,
        // Not testing bytes yet due to generics
        // #bytes: KtList,
      };

      final messageClass = reflectClass(ScalarsMessage);
      types.forEach((field, type) {
        test(MirrorSystem.getName(field), () {
          expect(messageClass.instanceMembers[field].returnType,
              reflectClass(type));
        });
      });
    });
  });
}
