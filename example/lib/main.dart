import 'package:immutable_proto/immutable_proto.dart';

import 'proto_generated/user.pb.dart' as proto;

part 'main.g.dart';

main() {
  final user = MutableUser()..firstName = 'a';
}

@ImmutableProto()
class MutableUser {
  String firstName;
}
