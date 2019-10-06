import 'package:analyzer/dart/element/element.dart';
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

int countOccurences(String string, String substring) {
  assert(string != null);
  assert(substring != null);

  int index = 0;
  int count = 0;
  while (index != -1) {
    index = string.indexOf(substring, index);
    if (index != -1) {
      count++;
      index += substring.length;
    }
  }
  return count;
}

bool isDirectlyNestedPbClass(ClassElement outer, ClassElement inner) {
  assert(outer != null);
  assert(inner != null);

  final prefix = '${outer.name}_';
  if (!inner.name.startsWith(prefix)) return false;
  return !inner.name.substring(prefix.length).contains('_');
}
