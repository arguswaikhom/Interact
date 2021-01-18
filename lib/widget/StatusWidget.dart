import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:interact/model/WhatsAppStatus.dart';
import 'package:interact/page/ImageView.dart';
import 'package:interact/page/VideoPlay.dart';
import 'package:interact/resource/AppColor.dart';
import 'package:interact/resource/AppString.dart';
import 'package:interact/utils/NotificationUtils.dart';
import 'package:interact/utils/WhatsAppStatusUtils.dart';
import 'package:path/path.dart';
import 'package:share/share.dart';

class StatusWidget extends StatelessWidget {
  final WhatsAppStatus status;
  const StatusWidget({Key key, @required this.status}) : super(key: key);

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
                  if (isContentVideo(status.contentUri)) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            VideoPlay(videoPath: status.contentUri)));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ImageView(imagePath: status.contentUri)));
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
      tag: status,
      child: Image.file(
        File(status.thumbnailUri),
        fit: BoxFit.contain,
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
    Share.shareFiles([status.contentUri]);
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
    File fileToBeSave = File(status.contentUri);
    final File newImage = await fileToBeSave
        .copy('${AppString.appDirectory}/${basename(fileToBeSave.path)}');
    MessageUtils(context).showLToast('Image saved to ${newImage.path}');
  }
}
