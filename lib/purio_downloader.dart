import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:purio_downloader/download_status.dart';

class PurioDownloader {
  static const MethodChannel _channel = MethodChannel('purio_downloader');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> get directory async {
    String appDocPath = "";
    if (kIsWeb == false && Platform.isAndroid) {
      Directory? appDocDir = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();

      appDocPath = appDocDir.path;
    } else {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      appDocPath = appDocDir.path;
    }

    return appDocPath;
  }

  static void cleanFilesinFolderStartingWith(String path, String fileName) {
    try {
      final dir = Directory(path);
      List<FileSystemEntity> fileSys = dir.listSync(recursive: false);

      List<FileSystemEntity> filesAppointedToDelete = fileSys
          .where((el) =>
              el is File && el.path.split("/").last.startsWith(fileName))
          .toList();

      for (var el in filesAppointedToDelete) {
        el.deleteSync();
      }
    } catch (e) {
      print('Could not delete the old files');
    }
  }

  static Future<bool> cleanCachedFile(String fileLocationUri) async {
  
    try {
      await File(fileLocationUri).delete();
      return Future.value(true);
    } catch (_) {
      return Future.value(false);
    }
  }

  List<Isolate> isolates = [];
  final controller = StreamController<DownloadStatus>();
  Stream<DownloadStatus> get streamedDownloadStatus => controller.stream;

  void download(String location, String fullDownloadUri,
      Map<String, dynamic> httpReqHeaders) async {
    if (!fullDownloadUri.contains('/')) {
      return;
    }
    isolates = [];
    ReceivePort receivePort = ReceivePort();
    String fileNameOfDownload = fullDownloadUri.split('/').last;

    controller.sink.add(DownloadStatus(
        state: DownloadState.downloadNotStarted, downloadProgress: 0.0));

    var isolatedDownloadParameters = IsolatedDownloadParameters(
        downloadUrl: fullDownloadUri,
        fileDirectory: location,
        fileName: fileNameOfDownload,
        headers: httpReqHeaders,
        sendPort: receivePort.sendPort);

    // isolates.add(await Isolate.spawn(runAnotherThing, receivePort.sendPort));
    isolates.add(await Isolate.spawn(isolatedDownload,
        isolatedDownloadParameters)); // Just one object can be passed

    receivePort.listen((data) {
      final currStatus = data as DownloadStatus;
      controller.add(currStatus);
      //print('Data: ${currStatus.downloadProgress}');

      if (currStatus.state == DownloadState.finishedDownloading) {
        print("Finished downloading from receive port");
        PurioDownloader.directory.then((value) => print(value));
        controller.add(DownloadStatus(
            state: DownloadState.finishedDownloading, downloadProgress: 100.0));

        receivePort.close();
        // OtaUpgradeHandler.installApk(fileNameOfDownload)
        //     .then((value) => );
        // To trigger the on onDone Method
      }
    }).onDone(() {
      // NEVER finished until receivePort not closed?
      // print("Finished downloading from receive port");
      // OtaUpgradeHandler.getFilesDir().then((value) => print(value));
      // OtaUpgradeHandler.installApk("MobiTransFlut_1.1.50.apk");

      controller.close();
      stop();
    });
  }

  void stop() {
    for (Isolate? i in isolates) {
      if (i != null) {
        i.kill(priority: Isolate.immediate);
        i = null;
        print('Terminated all isolates.');
      }
    }
  }
}

void isolatedDownload(IsolatedDownloadParameters parameters) async {
  var client = HttpClient();
  try {
    HttpClientRequest request =
        await client.getUrl(Uri.parse(parameters.downloadUrl));
    //await client.postUrl(Uri.parse(parameters.downloadUrl));

    // Add all headers
    parameters.headers.forEach((key, value) {
      request.headers.add(key, value, preserveHeaderCase: false);
    });

    // Optionally set up headers...
    // Optionally write to the request object...
    HttpClientResponse response = await request.close();
    // Process the response
    // final stringData = await response.transform(utf8.decoder).join();
    // print(stringData);

    // var response = await request.close();

    String dir = parameters.fileDirectory;
    //print(dir);

    List<List<int>> chunks = [];
    int downloaded = 0;

    response.listen((List<int> chunk) {
      // Display download progress
      //print('downloadPercentage: ${downloaded / response.contentLength * 100}');
      // parameters.sendPort.send(
      //     'downloadProgress: ${downloaded / response.contentLength * 100}');
      parameters.sendPort.send(DownloadStatus(
          state: DownloadState.downloading,
          downloadProgress: downloaded / response.contentLength * 100));

      chunks.add(chunk);
      downloaded += chunk.length;
    }, onDone: () async {
      // Display download progress
      //print('downloadProgress: ${downloaded / response.contentLength * 100}');

      // Save the file
      //File file = new File('$dir/$parameters.filename');
      File file = File(dir + '/' + parameters.fileName);
      final Uint8List bytes = Uint8List(response.contentLength);
      int offset = 0;
      for (List<int> chunk in chunks) {
        bytes.setRange(offset, offset + chunk.length, chunk);
        offset += chunk.length;
      }
      await file.writeAsBytes(bytes);

      // parameters.sendPort.send(
      //     'finishedDownloading: ${downloaded / response.contentLength * 100}');
      parameters.sendPort.send(DownloadStatus(
          state: DownloadState.finishedDownloading,
          downloadProgress: downloaded / response.contentLength * 100));

      return;
    });
  } finally {
    client.close();
  }
}

class IsolatedDownloadParameters {
  String downloadUrl;
  String fileDirectory;
  String fileName;
  Map<String, dynamic> headers;
  SendPort sendPort;

  IsolatedDownloadParameters(
      {required this.downloadUrl,
      required this.fileDirectory,
      required this.fileName,
      required this.headers,
      required this.sendPort});
}
