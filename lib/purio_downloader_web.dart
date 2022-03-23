import 'dart:async';
import 'dart:convert';
// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
//import 'dart:html' as html show window;
import 'dart:html' as html;
import 'dart:html';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:purio_downloader/download_status.dart';

/// A web implementation of the PurioDownloader plugin.
class PurioDownloader {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'purio_downloader',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = PurioDownloader();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'getPlatformVersion':
        return getPlatformVersion();
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'purio_downloader for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  /// Returns a [String] containing the version of the platform.
  static Future<String> getPlatformVersion() {
    final version = html.window.navigator.userAgent;
    return Future.value(version);
  }

  static Future<String?> get platformVersion async {
    return getPlatformVersion();
  }

  static Future<String> get directory async {
    String appDocPath = "";

    return appDocPath;
  }

  final controller = StreamController<DownloadStatus>();
  Stream<DownloadStatus> get streamedDownloadStatus => controller.stream;

  void download(String location, String fullDownloadUri,
      Map<String, String> httpReqHeaders) async {
    // or package:universal_html/prefer_universal/html.dart
    //print(httpReqHeaders.toString());

    try {
//       var resp =await HttpRequest.request(
//     fullDownloadUri,
//     method: 'GET',
//     //sendData: json.encode(data),
//     requestHeaders: httpReqHeaders,

//   );
//   if (resp.status == 200 ){
// resp.response
//   }
    // var flr = html.FileReader();

    //   var req = HttpRequest(); 
    //   for(var x in httpReqHeaders.entries){
    //     req.setRequestHeader(x.key, x.value);
    //   }      

    //   req
    //     ..onLoad.listen((e) {
    //       if (req.status == 200) {}
    //     })
    //     ..onError.listen((e) {
       
    //     })
    //     ..onLoadEnd.listen((event) {
    //       if(req.status == 200 && req.readyState == html.HttpRequest.DONE ){
    //           html.Blob blob = req.response;             
    //       }
    //      })
    //     ..onProgress.listen((e) {})
    //     ..open('GET', fullDownloadUri)
    //     ..send();

      // .then((resp) {
      //   print(resp.responseUrl);
      //   print(resp.responseText);
      // });

      http.Response response;
      response = await http.get(
          //Uri.parse("https://localhost:7083/NavApiBridge/ProtectedFile"),
          Uri.parse(fullDownloadUri),
          headers: httpReqHeaders);

      print(response.statusCode.toString());

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        // const String outputFilePath = 'example.jpg';

        //final downloadedFile = File(response.bodyBytes, outputFilePath);
        //final blob = html.Blob([downloadedFile]);

        final blob = html.Blob([response.bodyBytes]);

        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = fullDownloadUri.split('/').last;
        html.document.body?.children.add(anchor);

        // download
        anchor.click();

        // cleanup
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        controller.add(DownloadStatus(
            state: DownloadState.finishedDownloading, downloadProgress: 100.0));
        controller.close();
        return;
      }

      throw Exception("No File received");
    } catch (_) {
      //throw Exception("No File received");
    }
  }

  static Future<bool> cleanCachedFile(String fileLocationUri) async {
    return Future.value(true);
  }
}
