import 'dart:convert';

class FileCollectionModel {
  final String name;
  final int sId;
  final List<Collection> collections;

  FileCollectionModel({
    required this.name,
    required this.sId,
    required this.collections,
  });

  factory FileCollectionModel.fromRawJson(String str) =>
      FileCollectionModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FileCollectionModel.fromJson(Map<String, dynamic> json) =>
      FileCollectionModel(
        name: json["name"],
        sId: json["sId"],
        collections: List<Collection>.from(
          json["collections"].map((x) => Collection.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "sId": sId,
    "collections": List<dynamic>.from(collections.map((x) => x.toJson())),
  };
}

class Collection {
  final String name;
  final int cId;
  final List<FileElement> files;

  Collection({required this.name, required this.cId, required this.files});

  factory Collection.fromRawJson(String str) =>
      Collection.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
    name: json["name"] ?? '',
    cId: json["cId"] ?? 0,
    files: List<FileElement>.from(
      json["files"].map((x) => FileElement.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "cId": cId,
    "files": List<dynamic>.from(files.map((x) => x.toJson())),
  };
}

class FileElement {
  final String name;
  final String url;
  final int id;
  bool isDownloaded;
  String localPath;

  FileElement({
    required this.name,
    required this.url,
    required this.id,
    required this.isDownloaded,
    required this.localPath,
  });

  factory FileElement.fromRawJson(String str) =>
      FileElement.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FileElement.fromJson(Map<String, dynamic> json) => FileElement(
    name: json["name"] ?? '',
    url: json["url"] ?? '',
    id: json["id"] ?? 0,
    isDownloaded: json['isDownloaded'] == 1 || json['isDownloaded'] == true,
    localPath: json['localPath'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "url": url,
    "id": id,
    "isDownloaded": isDownloaded,
    "localPath": localPath,
  };
}
