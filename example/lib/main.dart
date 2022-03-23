import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
//import 'package:permission_handler/permission_handler.dart';
// import 'package:purio_downloader/download_status.dart';
// //import 'package:purio_downloader/purio_downloader.dart';
// import 'package:purio_downloader/purio_downloader_web.dart';
//import 'package:flutter_file_dialog/flutter_file_dialog.dart';

import 'package:purio_downloader/purio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  DownloadStatus currentDownloadEventStatus = DownloadStatus(
      state: DownloadState.downloadNotStarted, downloadProgress: 0.0);

  @override
  void initState() {
    super.initState();
    if(kIsWeb == false){
      initPlatformState();
    }
    

    isolatedDownload();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await PurioDownloader.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> isolatedDownload() async {
    String platformVersion = '';
    try {
      // Map<Permission, PermissionStatus> statuses = await [
      //   // Permission.mediaLibrary,
      //   //   Permission.photos,
      //   Permission.storage,
      // ].request();

      platformVersion = await PurioDownloader.platformVersion ?? "";
      print(await PurioDownloader.directory);
      String location = await PurioDownloader.directory;

      final downloadHandler = PurioDownloader();

      downloadHandler.download(
          location,
          'http://192.168.0.2:85/NavApiBridge/FileDownload/opp210569/20211026_174034_LR.jpg',
          {
            'AuthEndPoint':
                'http://192.168.0.2:9048/BC190/ODataV4/Company%28%27ECHO%20Metzingen%27%29/MobiTrans_NavOptions?\$format=json',
            //'HttpMethod': "GET",
            'AuthType': "Win",
            'UserDomain': "???",
            'UserName': "???",
            'UserPassword': "???",
          });
      downloadHandler.streamedDownloadStatus.listen((event) {
        //print(event.state.toString() +' ' + event.downloadProgress.toInt().toString());
        print('Download Progress' + event.downloadProgress.toString());
        if (mounted) setState(() => currentDownloadEventStatus = event);
      }).onDone(() async {
        // final params =
        //     SaveFileDialogParams(sourceFilePath: location+'/20211026_174034_LR.jpg');
        // final filePath = await FlutterFileDialog.saveFile(params: params);
        // print(filePath);
      });
    } catch (e) {
      print('Failed to make download update. Details: $e');
    }

    //  on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
