import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Get thumbnail of a video
getVideoThumbnail(String videoPath, Function onSuccess) async {
  final imagePath = await VideoThumbnail.thumbnailFile(
    video: videoPath,
    thumbnailPath: (await getTemporaryDirectory()).path,
    imageFormat: ImageFormat.JPEG,
    quality: 10,
  );
  onSuccess(imagePath);
}
