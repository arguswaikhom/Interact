import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:interact/controller/PermissionController.dart';
import 'package:interact/resource/AppColor.dart';
import 'package:interact/resource/AppDimension.dart';
import 'package:interact/resource/AppString.dart';
import 'package:interact/widget/StatusListWidget.dart';

final Directory _photoDir = Directory(AppString.whatsappStatusLocation);

class StatusListPage extends StatefulWidget {
  @override
  _StatusListPageState createState() => _StatusListPageState();
}

class _StatusListPageState extends State<StatusListPage> {
  var _allPermissionGranted;

  @override
  void initState() {
    super.initState();

    /// Request storage permission
    PermissionController().requestStoragePermission(
        () => {
              // Requested storage permission was granted
              setState(() {
                _allPermissionGranted = true;
              })
            },
        () => {
              /// Requested storage permission was denied
              setState(() {
                _allPermissionGranted = false;
              })
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.appName),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(color: AppColor.primary),
        child: _getPageBody(),
      ),
    );
  }

  /// Return the current body widget to display
  _getPageBody() {
    /// if [_allPermissionGranted] is null; the app is still asking for the storage permission
    if (_allPermissionGranted == null) {
      /// Display a [CircularProgressIndicator()] until the user permitted or denied the requested permissions
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    /// Get the stories to display if the permissipns are granted
    if (_allPermissionGranted) {
      return _getStoryList();
    }

    /// [_allPermissionGranted] = false
    /// Display permission denied message if the permissions are not granted
    return Center(
      child: Text(
        'App required storage permission!!',
        style: TextStyle(fontSize: 18.0, color: AppColor.grey5),
      ),
    );
  }

  _getStoryList() {
    /// Check whether the WhatsApp status folder is present or not in the user device
    if (!Directory("${_photoDir.path}").existsSync()) {
      /// WhatsApp status folder is not present
      return Center(
        child: Text(
          "All WhatsApp images should appear here",
          style: TextStyle(fontSize: 18.0, color: AppColor.grey5),
        ),
      );
    }

    // Get all the status from the WhatsApp status folder
    var imageList = _photoDir
        .listSync()
        .map((item) => item.path)
        .where((item) => item.endsWith(".jpg"))
        .toList(growable: false);

    /// If there is no status in the folder; display "No status found" message
    if (imageList.length == 0) {
      return Center(
        child: Text(
          "Sorry, No Images Where Found.",
          style: TextStyle(fontSize: 18.0, color: AppColor.grey5),
        ),
      );
    }

    /// Display all the status in a Staggered grid view
    return Container(
      child: StaggeredGridView.countBuilder(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppDimension.primary),
        crossAxisCount: 4,
        itemCount: imageList.length,
        itemBuilder: (context, index) {
          return StatusListWidget(
            imageUri: imageList[index],
          );
        },
        staggeredTileBuilder: (i) => StaggeredTile.fit(2),
        mainAxisSpacing: AppDimension.primary,
        crossAxisSpacing: AppDimension.primary,
      ),
    );
  }
}
