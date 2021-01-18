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

class StatusListPage extends StatefulWidget {
  @override
  _StatusListPageState createState() => _StatusListPageState();
}

class _StatusListPageState extends State<StatusListPage> {
  var _selectedChip = AppString.filterWhatsApp;

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 48,
          child: _getChoiceChips(),
        ),
        Expanded(
          child: _getStatusListBody(),
        ),
      ],
    );
  }

  _getChoiceChips() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _getChoiceChip(AppString.filterWhatsApp),
        _getChoiceChip(AppString.filterWhatsAppBusiness),
        _getChoiceChip(AppString.filterWhatsAppDual),
        _getChoiceChip(AppString.filterGBWhatsApp),
      ],
    );
  }

  _getChoiceChip(String label) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        backgroundColor: AppColor.dark2,
        // shadowColor: Colors.purple,
        labelStyle: TextStyle(color: Colors.white),
        selectedColor: AppColor.skyBlue,
        label: Text(label),
        selected: _selectedChip == label,
        onSelected: (bool selected) {
          /// If the user click the same chip which was already selected; do nothing
          if (label == _selectedChip) return;
          setState(() {
            _selectedChip = selected ? label : null;
          });
        },
      ),
    );
  }

  _getStatusListBody() {
    return FutureBuilder(
      future: PermissionController().requestStoragePermission(),
      builder: (context, snapsort) {
        if (snapsort.connectionState == ConnectionState.done) {
          if (snapsort.hasData) {
            if (snapsort.data) {
              return _getStoryList();
            } else {
              return Center(
                child: Text(
                  'App required storage permission!!',
                  style: TextStyle(fontSize: 18.0, color: AppColor.grey5),
                ),
              );
            }
          } else {
            return Container();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  _getStoryList() {
    final Directory _photoDir = Directory(getStatusPath(_selectedChip));

    /// Check whether the WhatsApp status folder is present or not in the user device
    if (!Directory("${_photoDir.path}").existsSync()) {
      /// WhatsApp status folder is not present
      return Center(
        child: Text(
          "WhatsApp images should appear here",
          style: TextStyle(fontSize: 18.0, color: AppColor.grey5),
        ),
      );
    }

    return FutureBuilder(
      future: _getStatusList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data.length > 0) {
            return _getStaggeredList(snapshot.data);
          } else {
            /// If there is no status in the folder; display "No status found" message
            return Center(
              child: Text(
                "Sorry, No Images Where Found.",
                style: TextStyle(fontSize: 18.0, color: AppColor.grey5),
              ),
            );
          }
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  _getStatusList() async {
    final Directory _photoDir = Directory(getStatusPath(_selectedChip));
    var _contentList = _photoDir
        .listSync()
        .map((item) => item.path)
        .where((item) =>
            item.endsWith(AppString.formatStatusImage) ||
            item.endsWith(AppString.formatStatusVideo))
        .toList(growable: false);

    if (_contentList.length == 0) return [];

    List<WhatsAppStatus> statusList = [];
    for (int i = 0; i < _contentList.length; i++) {
      String uri = _contentList[i];
      if (isContentVideo(uri)) {
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
            status: item[index],
          );
        },
        staggeredTileBuilder: (i) => StaggeredTile.fit(2),
        mainAxisSpacing: AppDimension.primary,
        crossAxisSpacing: AppDimension.primary,
      ),
    );
  }
}
