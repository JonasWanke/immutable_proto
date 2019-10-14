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
