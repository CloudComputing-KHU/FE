/// 업로드·목록 API와 맞출 공통 사진 엔티티.
class Photo {
  const Photo({
    required this.id,
    required this.imageUrl,
    this.caption,
  });

  final String id;
  final String imageUrl;
  final String? caption;
}
