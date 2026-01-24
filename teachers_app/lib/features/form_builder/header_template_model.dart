import 'dart:convert';

/// Enum for text alignment in headers
enum HeaderAlignment { left, center, right }

/// Model representing a question paper header template
class HeaderTemplate {
  final String id;
  final String name;
  final bool isCustom;
  final String? instituteName;
  final String? logoBase64; // Base64 encoded image or null
  final String? subtitle; // e.g., "Internal Assessment"
  final String? examTitle; // e.g., "Mid-Term Examination"
  final bool showDate;
  final bool showDuration;
  final bool showMaxMarks;
  final bool showSubjectField;
  final bool showClassField;
  final HeaderAlignment titleAlignment;
  final bool showBorder;
  final List<String>
  customFields; // User-defined fields like "Reg No", "QP Code", etc.

  const HeaderTemplate({
    required this.id,
    required this.name,
    this.isCustom = false,
    this.instituteName,
    this.logoBase64,
    this.subtitle,
    this.examTitle,
    this.showDate = false,
    this.showDuration = false,
    this.showMaxMarks = false,
    this.showSubjectField = false,
    this.showClassField = false,
    this.titleAlignment = HeaderAlignment.center,
    this.showBorder = false,
    this.customFields = const [],
  });

  HeaderTemplate copyWith({
    String? id,
    String? name,
    bool? isCustom,
    String? instituteName,
    String? logoBase64,
    String? subtitle,
    String? examTitle,
    bool? showDate,
    bool? showDuration,
    bool? showMaxMarks,
    bool? showSubjectField,
    bool? showClassField,
    HeaderAlignment? titleAlignment,
    bool? showBorder,
    List<String>? customFields,
  }) {
    return HeaderTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      isCustom: isCustom ?? this.isCustom,
      instituteName: instituteName ?? this.instituteName,
      logoBase64: logoBase64 ?? this.logoBase64,
      subtitle: subtitle ?? this.subtitle,
      examTitle: examTitle ?? this.examTitle,
      showDate: showDate ?? this.showDate,
      showDuration: showDuration ?? this.showDuration,
      showMaxMarks: showMaxMarks ?? this.showMaxMarks,
      showSubjectField: showSubjectField ?? this.showSubjectField,
      showClassField: showClassField ?? this.showClassField,
      titleAlignment: titleAlignment ?? this.titleAlignment,
      showBorder: showBorder ?? this.showBorder,
      customFields: customFields ?? this.customFields,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isCustom': isCustom,
    'instituteName': instituteName,
    'logoBase64': logoBase64,
    'subtitle': subtitle,
    'examTitle': examTitle,
    'showDate': showDate,
    'showDuration': showDuration,
    'showMaxMarks': showMaxMarks,
    'showSubjectField': showSubjectField,
    'showClassField': showClassField,
    'titleAlignment': titleAlignment.name,
    'showBorder': showBorder,
    'customFields': customFields,
  };

  factory HeaderTemplate.fromJson(Map<String, dynamic> json) => HeaderTemplate(
    id: json['id'],
    name: json['name'],
    isCustom: json['isCustom'] ?? false,
    instituteName: json['instituteName'],
    logoBase64: json['logoBase64'],
    subtitle: json['subtitle'],
    examTitle: json['examTitle'],
    showDate: json['showDate'] ?? false,
    showDuration: json['showDuration'] ?? false,
    showMaxMarks: json['showMaxMarks'] ?? false,
    showSubjectField: json['showSubjectField'] ?? false,
    showClassField: json['showClassField'] ?? false,
    titleAlignment: HeaderAlignment.values.firstWhere(
      (e) => e.name == json['titleAlignment'],
      orElse: () => HeaderAlignment.center,
    ),
    showBorder: json['showBorder'] ?? false,
    customFields: (json['customFields'] as List?)?.cast<String>() ?? [],
  );

  /// Serialize to JSON string
  String serialize() => jsonEncode(toJson());

  /// Deserialize from JSON string
  factory HeaderTemplate.deserialize(String json) =>
      HeaderTemplate.fromJson(jsonDecode(json));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeaderTemplate &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
