/// 电台数据模型
class Station {
  final String name;
  final String category;
  final String type; // mp3 | m3u8
  final String url;
  final String style1;
  final String style2;
  final String scene;
  final String? custom;

  const Station({
    required this.name,
    required this.category,
    required this.type,
    required this.url,
    required this.style1,
    required this.style2,
    required this.scene,
    this.custom,
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
      };
}
