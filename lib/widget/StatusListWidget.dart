import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:interact/resource/AppColor.dart';
import 'package:interact/resource/AppString.dart';
import 'package:interact/utils/NotificationUtils.dart';
import 'package:path/path.dart';
import 'package:share/share.dart';

class StatusListWidget extends StatelessWidget {
  final imageUri;

  const StatusListWidget({Key key, @required this.imageUri}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Stack(
        children: [
          /// Status Image view
          Hero(
            tag: imageUri,
            child: Image.file(
              File(imageUri),
              fit: BoxFit.fitWidth,
            ),
          ),

          /// Option menu
          _getOptionMenu(context),

          /// Ripples effect on click
          /*Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: AppColor.primary,
                onTap: () {},
              ),
            ),
          ),*/
        ],
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
    Share.shareFiles([imageUri]);
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
    File imageToBeSave = File(imageUri);
    final File newImage = await imageToBeSave
        .copy('${AppString.appDirectory}/${basename(imageToBeSave.path)}');
    MessageUtils(context).showLToast('Image saved to ${newImage.path}');
  }
}
