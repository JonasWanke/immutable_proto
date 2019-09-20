import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';

String lowerFirstChar(String original) {
  return original[0].toLowerCase() + original.substring(1);
}

String upperFirstChar(String original) {
  return original[0].toUpperCase() + original.substring(1);
}

String snakeToLowerCamel(String original) {
  return lowerFirstChar(
      original.split('_').map((p) => upperFirstChar(p.toLowerCase())).join(''));
}

class FieldGetterVisitor extends SimpleElementVisitor {
  FieldGetterVisitor(this.fieldName) : assert(fieldName != null);

  final String fieldName;
  FieldElement field;

  @override
  visitFieldElement(FieldElement element) {
    if (element.name == fieldName) field = element;
  }
}