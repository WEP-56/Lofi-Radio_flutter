class Station {
  final String name;
  final String category;
  final String type;
  final String url;
  final String style1;
  final String style2;
  final String scene;
  final String? custom;
  final bool isUserStation;

  const Station({
    required this.name,
    required this.category,
    required this.type,
    required this.url,
    required this.style1,
    required this.style2,
    required this.scene,
    this.custom,
    this.isUserStation = false,
  });

  factory Station.fromJson(Map<String, dynamic> json) => Station(
    name: json['name'] as String,
    category: json['category'] as String,
    type: json['type'] as String,
    url: json['url'] as String,
    style1: json['style1'] as String? ?? '',
    style2: json['style2'] as String? ?? '',
    scene: json['scene'] as String? ?? '',
    custom: json['custom'] as String?,
    isUserStation: json['isUserStation'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'type': type,
    'url': url,
    'style1': style1,
    'style2': style2,
    'scene': scene,
    if (custom != null) 'custom': custom,
    'isUserStation': isUserStation,
  };

  Station copyWith({
    String? name,
    String? category,
    String? type,
    String? url,
    String? style1,
    String? style2,
    String? scene,
    Object? custom = _sentinel,
    bool? isUserStation,
  }) {
    return Station(
      name: name ?? this.name,
      category: category ?? this.category,
      type: type ?? this.type,
      url: url ?? this.url,
      style1: style1 ?? this.style1,
      style2: style2 ?? this.style2,
      scene: scene ?? this.scene,
      custom: identical(custom, _sentinel) ? this.custom : custom as String?,
      isUserStation: isUserStation ?? this.isUserStation,
    );
  }
}

const Object _sentinel = Object();
