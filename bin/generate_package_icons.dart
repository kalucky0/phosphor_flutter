import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

import 'extensions.dart';
import 'style_file_data.dart';
import 'utils.dart';

/// Generated the main class of the package that exposes all the style classes
void generateMainClass(List<StyleFileData> styles) {
  print('Generating style abstract class phosphor_icons.dart file');

  final phosphorLib = Library(
    (libraryBuilder) => libraryBuilder
      ..directives.addAll([
        ...styles.map(
          (style) => Directive.export(
            'package:phosphor_flutter/src/${style.classFileName}',
          ),
        ),
      ]),
  );

  final emitter = DartEmitter();
  final generatedFileContent = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  ).format('${phosphorLib.accept(emitter)}');

  saveContentToFile(
    filePath: '../lib/src/phosphor_icons.dart',
    content: generatedFileContent,
  );
}

Method buildBaseFieldIcon(dynamic icon) {
  final properties = icon['properties'] as Map<String, dynamic>;
  final rawName = properties['name'] as String;
  final fullName = rawName.split(",").first;
  final name = formatName(fullName, style: 'regular');
  final styles = StyleFileData.values;
  var code = 'switch (style) {';
  for (final style in styles) {
    code +=
        '''
case PhosphorIconsStyle.${style.styleName}:
  return ${style.className}.$name;
''';
  }
  code += '}';
  return Method(
    (methodBuilder) => methodBuilder
      ..name = name
      ..static = true
      ..docs.addAll(
        styles.map(
          (style) =>
              '/// ${style.styleName}: ![$fullName](https://raw.githubusercontent.com/phosphor-icons/core/main/assets/${style.styleName}/$fullName.svg)',
        ),
      )
      ..optionalParameters.add(
        Parameter(
          (parameterBuilder) => parameterBuilder
            ..name = 'style'
            ..defaultTo = Code('PhosphorIconsStyle.regular')
            ..type = Reference('PhosphorIconsStyle'),
        ),
      )
      ..body = Code(code)
      ..returns = Reference('PhosphorIconData'),
  );
}

/// reads the phosphor json  of one style and generates a dart class
/// with all the phosphor icons constants for that style
void generateStyleClass(List icons, {required StyleFileData style}) {
  print('Generating style abstract class ${style.classFileName} file');

  final fields =
      icons
          // filter only valid graphs by idx of the style
          .where((icon) => icon['setIdx'] as int == style.idx)
          // Generate the field for the graph
          .map((icon) => buildFieldIconByStyle(icon, style: style))
          .toList()
        // sort the element alphabetically
        ..sort((a, b) => a.name.compareTo(b.name));

  final allFields = [...fields];

  final phosphorIconsClass = Class(
    (classBuilder) => classBuilder
      ..abstract = false
      ..name = style.className
      ..fields.addAll(allFields)
      ..annotations.add(CodeExpression(Code('staticIconProvider')))
      ..constructors.add(
        Constructor(
          (constructorBuilder) => constructorBuilder..constant = true,
        ),
      ),
  );

  final fontFamilyConst = Field(
    (b) => b
      ..name = '_f'
      ..type = Reference('String')
      ..modifier = FieldModifier.constant
      ..assignment = Code("'Phosphor${style.styleName.capitalize()}'"),
  );
  final fontPackageConst = Field(
    (b) => b
      ..name = '_p'
      ..type = Reference('String')
      ..modifier = FieldModifier.constant
      ..assignment = Code("'phosphor_flutter'"),
  );

  final phosphorLib = Library(
    (libraryBuilder) => libraryBuilder
      ..directives.add(Directive.import('package:flutter/widgets.dart'))
      ..body.addAll([fontFamilyConst, fontPackageConst, phosphorIconsClass]),
  );

  final emitter = DartEmitter();
  final generatedFileContent = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  ).format('${phosphorLib.accept(emitter)}');
  saveContentToFile(
    filePath: '../lib/src/${style.classFileName}',
    content: generatedFileContent,
  );
}

Field buildFieldIconByStyle(dynamic icon, {required StyleFileData style}) {
  final properties = icon['properties'] as Map<String, dynamic>;
  final fullName = properties['name'] as String;
  final firstName = fullName.split(",").first;
  final name = formatName(firstName, style: style.styleName);

  final iconDocs =
      '/// ![$firstName](https://raw.githubusercontent.com/phosphor-icons/core/main/assets/${style.styleName}/$firstName.svg)';

  late Code codeStatement;

  String iconDataLiteral(String hex) =>
      "IconData($hex, fontFamily: _f, fontPackage: _p, matchTextDirection: true)";

  final graphCode = properties['code'] as int;
  final hexCode = '0x' + graphCode.toRadixString(16);
  codeStatement = Code(iconDataLiteral(hexCode));

  return Field(
    (fieldBuilder) => fieldBuilder
      ..docs.add(iconDocs)
      ..modifier = FieldModifier.constant
      ..static = true
      ..name = name
      ..assignment = codeStatement,
  );
}
