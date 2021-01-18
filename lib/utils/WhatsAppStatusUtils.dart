import 'package:interact/resource/AppString.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Get thumbnail of a video
getVideoThumbnail(String videoPath) async {
  return await VideoThumbnail.thumbnailFile(
    video: videoPath,
    thumbnailPath: (await getTemporaryDirectory()).path,
    imageFormat: ImageFormat.JPEG,
    quality: 10,
  );
}

getStatusPath(String filter) {
  switch (filter) {
    case AppString.filterWhatsAppBusiness:
      return AppString.whatsAppBusinessStatusLocation;
    case AppString.filterWhatsAppDual:
      return AppString.whatsAppDualStatusLocation;
    case AppString.filterGBWhatsApp:
      return AppString.whatsAppGBStatusLocation;
    default:
      return AppString.whatsappStatusLocation;
  }
}

isContentVideo(String uri) {
  return uri.toString().toLowerCase().endsWith(AppString.formatStatusVideo);
}
