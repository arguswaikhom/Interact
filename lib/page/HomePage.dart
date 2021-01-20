import 'package:flutter/material.dart';
import 'package:interact/page/SavedStatusPage.dart';
import 'package:interact/page/StatusListPage.dart';
import 'package:interact/resource/AppColor.dart';
import 'package:interact/resource/AppString.dart';
import 'package:interact/resource/AppStyle.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentNav = AppString.navWhatsAppStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentNav),
        elevation: 0,
      ),
      drawer: Drawer(
        child: Container(
          child: _getNavDrawer(),
          decoration: BoxDecoration(color: AppColor.primary),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: AppColor.primary),
        child: _getPageBody(),
      ),
    );
  }

  _getNavDrawer() {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Image(image: AssetImage(AppString.assetImgLogo)),
        ),
        ListTile(
          title: Text(AppString.navWhatsAppStatus,
              style: AppStyle.textStyleNavDrawer),
          onTap: () {
            Navigator.pop(context);
            if (_currentNav == AppString.navWhatsAppStatus) return;
            setState(() {
              _currentNav = AppString.navWhatsAppStatus;
            });
          },
        ),
        ListTile(
          title: Text(AppString.navSavedStatus,
              style: AppStyle.textStyleNavDrawer),
          onTap: () {
            Navigator.pop(context);
            if (_currentNav == AppString.navSavedStatus) return;
            setState(() {
              _currentNav = AppString.navSavedStatus;
            });
          },
        ),
      ],
    );
  }

  _getPageBody() {
    /// Return the widget to display based on the selected navigation
    switch (_currentNav) {
      case AppString.navWhatsAppStatus:
        return StatusListPage();
      case AppString.navSavedStatus:
        return SaveStatusPage();
      default:
        return Container();
    }
  }
}
