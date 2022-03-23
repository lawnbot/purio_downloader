import 'dart:async';

import 'package:purio_downloader/download_status.dart';

class PurioDownloader {
  final controller = StreamController<DownloadStatus>();
  Stream<DownloadStatus> get streamedDownloadStatus => controller.stream;

  static Future<String?> get platformVersion async {
    Future.value('');
  }

  static Future<String> get directory async {
    return Future.value('');
  }

  void download(String location, String fullDownloadUri,
      Map<String, dynamic> httpReqHeaders) async {
    throw UnimplementedError('Not implemented');
  }

  static Future<void> cleanCachedFile(String fileLocationUri) async {
        throw UnimplementedError('Not implemented');
  }
}
