class LottieImageAsset {

  final int width;
  final int height;
  final String id;
  final String fileName;

  const LottieImageAsset(this.width, this.height, this.id, this.fileName);

  LottieImageAsset.fromMap(Map<String, dynamic>  map)
      : this.width = map['w'],
        this.height = map['h'],
        this.id = map['id'],
        this.fileName = map['p'];

}