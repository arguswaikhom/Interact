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
  final bool enableSave;
  final bool enableDelete;
  final Function onDelete;
  final WhatsAppStatus status;

  const StatusWidget(
      {Key key,
      @required this.status,
      this.enableSave = true,
      this.enableDelete = false,
      this.onDelete})
      : super(key: key);

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
          _getPrepareMenu(context),
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
  Widget _getPrepareMenu(context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert_rounded,
        color: AppColor.grey5,
      ),
      onSelected: (value) {
        switch (value) {
          case AppString.optionShare:
            _onClickShareStatus();
            break;
          case AppString.optionSaveStatus:
            _onClickSaveStatus(context);
            break;
          case AppString.optionDelete:
            _onClickDeleteStatus(context);
            break;
        }
      },
      itemBuilder: (context) => _getOptionMenus(),
    );
  }

  List<PopupMenuItem> _getOptionMenus() {
    List<PopupMenuItem> menus = [
      _getOptionMenu(AppString.optionShare, Icons.share_rounded)
    ];

    if (enableSave)
      menus.add(_getOptionMenu(
        AppString.optionSaveStatus,
        Icons.save,
      ));

    if (enableDelete)
      menus.add(_getOptionMenu(
        AppString.optionDelete,
        Icons.delete,
      ));

    return menus;
  }

  PopupMenuItem _getOptionMenu(label, icon) {
    return PopupMenuItem(
      value: label,
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
            child: Icon(icon),
          ),
          Text(label)
        ],
      ),
    );
  }

  /// Share the current image to other app
  _onClickShareStatus() {
    Share.shareFiles([status.contentUri]);
  }

  /// Save the current image to user device
  _onClickSaveStatus(context) {
    if (!enableSave) return;

    /// If the app directory is not present; create and save the image
    /// otherwise just save the image
    if (Directory("${Directory(AppString.savedStatusDirectory).path}")
        .existsSync()) {
      _saveStatus(context);
    } else {
      Directory(AppString.savedStatusDirectory).createSync(recursive: true);
      _saveStatus(context);
    }
  }

  _onClickDeleteStatus(context) async {
    if (!enableDelete) return;
    try {
      File(status.contentUri).delete();
      if (onDelete != null) onDelete();
      MessageUtils(context).showLToast('File deleted');
    } catch (_) {}
  }

  /// Save the current image to the user device
  _saveStatus(context) async {
    File fileToBeSave = File(status.contentUri);
    final File newImage = await fileToBeSave.copy(
        '${AppString.savedStatusDirectory}/${basename(fileToBeSave.path)}');
    MessageUtils(context).showLToast('Image saved to ${newImage.path}');
  }
}
