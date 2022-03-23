
class DownloadStatus {
  DownloadState state = DownloadState.downloadNotStarted;
  double downloadProgress = 0.0;
  DownloadStatus({required this.state, required this.downloadProgress});
}

enum DownloadState {
  downloadNotStarted,
  downloading,
  finishedDownloading,
  error
}
