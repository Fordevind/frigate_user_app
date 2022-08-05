import 'package:flutter/foundation.dart';

class Provider {
  const Provider({
    @required this.name,
    this.title,
    this.description,
    @required this.urls,
    this.imageLocal,
    this.imageURL
  }) : assert(imageURL != null || imageLocal != null);
  final String name;
  final String title;
  final String description;
  final List<String> urls;
  final String imageLocal;
  final String imageURL;

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      name: json['name'],
      urls: List.from(json['url']),
      imageURL: json['logo'],
      imageLocal: json['imageLocal'],
      description: json['descr'],
      title: json['title']
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = new Map();
    json = {
      'name': name,
      'url': urls,
      'logo': imageURL,
      'imageLocal': imageLocal,
      'descr': description,
      'title': title,
    };

    return json;
  }
}