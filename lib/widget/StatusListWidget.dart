import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:interact/page/ImageView.dart';
import 'package:interact/page/VideoPlay.dart';
import 'package:interact/resource/AppColor.dart';
import 'package:interact/resource/AppString.dart';
import 'package:interact/utils/NotificationUtils.dart';
import 'package:interact/utils/WhatsAppStatusUtils.dart';
import 'package:path/path.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class StatusListWidget extends StatefulWidget {
  final contentUri;

  const StatusListWidget({Key key, this.contentUri}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    print(contentUri);
    return _StatusListWidget(
      contentUri: contentUri,
    );
  }
}

class _StatusListWidget extends State<StatusListWidget> {
  final contentUri;
  final isVideoContent;

  var videoThumbnail;

  _StatusListWidget({@required this.contentUri})
      : isVideoContent = contentUri
            .toString()
            .toLowerCase()
            .endsWith(AppString.formatStatusVideo);

  @override
  void initState() {
    super.initState();

    /// If the content is video; get the thumbnail of the video to display
    if (isVideoContent) {
      getVideoThumbnail(
          contentUri,
          (imagePath) => {
                setState(() {
                  videoThumbnail = imagePath;
                })
              });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Stack(
        children: [
          /// Status view
          _getStatusView(),

          /// Ripples effect on click
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: AppColor.primary,
                onTap: () {
                  if (isVideoContent) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            VideoPlay(videoPath: contentUri)));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ImageView(imagePath: contentUri)));
                  }
                },
              ),
            ),
          ),

          /// Option menu
          _getOptionMenu(context),
        ],
      ),
    );
  }

  _getStatusView() {
    return Hero(
      tag: contentUri,
      child: isVideoContent
          ? videoThumbnail == null
              ? Container()
              : Image.file(
                  File(videoThumbnail),
                  fit: BoxFit.fitWidth,
                )
          : Image.file(
              File(contentUri),
              fit: BoxFit.fitWidth,
            ),
    );
  }

  /// Return a widget that display as a pop up menu
  Widget _getOptionMenu(context) {
    const valueShare = 0;
    const valueSave = 1;

    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert_rounded,
        color: AppColor.grey5,
      ),
      onSelected: (value) {
        if (value == valueShare)
          _onClickShareStatus();
        else if (value == valueSave) _onClickSaveStatus(context);
      },
      itemBuilder: (context) => [
        /// Share option menu
        PopupMenuItem(
          value: valueShare,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.share),
              ),
              Text('Share')
            ],
          ),
        ),

        /// Save image option menu
        PopupMenuItem(
          value: valueSave,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.save),
              ),
              Text('Save to gallery')
            ],
          ),
        ),
      ],
    );
  }

  /// Share the current image to other app
  _onClickShareStatus() {
    Share.shareFiles([contentUri]);
  }

  /// Save the current image to user device
  _onClickSaveStatus(context) {
    /// If the app directory is not present; create and save the image
    /// otherwise just save the image
    if (Directory("${Directory(AppString.appDirectory).path}").existsSync()) {
      _saveStatus(context);
    } else {
      Directory(AppString.appDirectory).createSync(recursive: true);
      _saveStatus(context);
    }
  }

  /// Save the current image to the user device
  _saveStatus(context) async {
    File fileToBeSave = File(contentUri);
    final File newImage = await fileToBeSave
        .copy('${AppString.appDirectory}/${basename(fileToBeSave.path)}');
    MessageUtils(context).showLToast('Image saved to ${newImage.path}');
  }
}
