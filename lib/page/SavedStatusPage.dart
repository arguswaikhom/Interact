import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:interact/controller/PermissionController.dart';
import 'package:interact/model/WhatsAppStatus.dart';
import 'package:interact/resource/AppColor.dart';
import 'package:interact/resource/AppDimension.dart';
import 'package:interact/resource/AppString.dart';
import 'package:interact/utils/WhatsAppStatusUtils.dart';
import 'package:interact/widget/StatusWidget.dart';

class SaveStatusPage extends StatefulWidget {
  SaveStatusPage({Key key}) : super(key: key);

  @override
  _SaveStatusPageState createState() => _SaveStatusPageState();
}

class _SaveStatusPageState extends State<SaveStatusPage> {
  final Directory _photoDir = Directory(AppString.savedStatusDirectory);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PermissionController().requestStoragePermission(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            if (snapshot.data) {
              /// Storage permission granted; show saved status
              return _getStoryList();
            } else {
              /// Storage permission not granted
              return Center(
                child: Text(
                  'App required storage permission!!',
                  style: TextStyle(fontSize: 18.0, color: AppColor.grey5),
                ),
              );
            }
          } else {
            /// Show a container while displaying the permission request dialog
            return Container();
          }
        } else {
          /// Show progress while checking for the permission
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  _getStoryList() {
    /// Check whether the saved status folder is present or not in the user device
    if (!Directory("${_photoDir.path}").existsSync()) {
      /// Saved status folder is not present
      return Center(
        child: Text(
          "Saved status should appear here",
          style: TextStyle(fontSize: 18.0, color: AppColor.grey5),
        ),
      );
    }

    return FutureBuilder(
      future: _getStatusList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data.length > 0) {
            /// Display the saved status in a staggered grid list
            return _getStaggeredList(snapshot.data);
          } else {
            /// No saved status found in the directory
            return Center(
              child: Text(
                "No saved status where found.",
                style: TextStyle(fontSize: 18.0, color: AppColor.grey5),
              ),
            );
          }
        }

        /// Display a progress indicator while loading the saves status
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  _getStatusList() async {
    /// Fetch all the .jpg and .mp4 files from the saved status directory
    var contentList = _photoDir
        .listSync()
        .map((item) => item.path)
        .where((item) =>
            item.endsWith(AppString.formatStatusImage) ||
            item.endsWith(AppString.formatStatusVideo))
        .toList(growable: false);

    if (contentList.length == 0) return [];

    /// Create a list of [WhatsAppStatus] objects from the [contentList]
    List<WhatsAppStatus> statusList = [];
    for (int i = 0; i < contentList.length; i++) {
      String uri = contentList[i];
      if (isContentVideo(uri)) {
        /// Generate thumbnail for all the videos
        String thumbnail = await getVideoThumbnail(uri);
        statusList
            .add(WhatsAppStatus(contentUri: uri, thumbnailUri: thumbnail));
      } else {
        statusList.add(WhatsAppStatus(contentUri: uri, thumbnailUri: uri));
      }
    }

    return statusList;
  }

  _getStaggeredList(item) {
    return Container(
      child: StaggeredGridView.countBuilder(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppDimension.primary),
        crossAxisCount: 4,
        itemCount: item.length,
        itemBuilder: (context, index) {
          return StatusWidget(
            enableSave: false,
            enableDelete: true,
            status: item[index],
            onDelete: () {
              setState(() {});
            },
          );
        },
        staggeredTileBuilder: (i) => StaggeredTile.fit(2),
        mainAxisSpacing: AppDimension.primary,
        crossAxisSpacing: AppDimension.primary,
      ),
    );
  }
}
