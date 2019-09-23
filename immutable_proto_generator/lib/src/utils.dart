import 'package:analyzer/dart/element/type.dart';

String lowerFirstChar(String original) {
  assert(original != null);
  return original[0].toLowerCase() + original.substring(1);
}

String upperFirstChar(String original) {
  assert(original != null);
  return original[0].toUpperCase() + original.substring(1);
}

String snakeToLowerCamel(String original) {
  assert(original != null);
  return lowerFirstChar(
      original.split('_').map((p) => upperFirstChar(p.toLowerCase())).join(''));
}

String snakeCamelToUpperCamel(String original) {
  assert(original != null);
  return original.split('_').map((p) => upperFirstChar(p)).join('');
}

const KNOWN_LIST_TYPES = ['List', 'KtList', 'KtMutableList'];
bool isTypeList(DartType type) {
  return KNOWN_LIST_TYPES.contains(type.name);
}
