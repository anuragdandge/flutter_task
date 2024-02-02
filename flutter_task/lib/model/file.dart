class FileModel {
  late List<String>? files;
  late String? folder;

  FileModel({required this.files, required this.folder});

  FileModel.fromJson(Map<String, dynamic> json) {
    files = json['files'].cast<String>();
    folder = json['folderName'];
  }
}
