import 'extensions.dart';

enum StyleFileData {
  regular(styleName: 'regular', fontFileName: 'Phosphor.ttf', idx: 0),

  bold(styleName: 'bold', fontFileName: 'Phosphor-Bold.ttf', idx: 3);

  const StyleFileData({
    required this.styleName,
    required this.fontFileName,
    required this.idx,
  });

  final String styleName;
  final String fontFileName;
  final int idx;

  String get directoryName => styleName;
  String get docsLine => '/// ${styleName.capitalize()} Icons';
  String get className => 'PhosphorIcons${styleName.capitalize()}';
  String get classFileName => 'phosphor_icons_$styleName.dart';
  String get classConstructorLine => '$className()';
}
