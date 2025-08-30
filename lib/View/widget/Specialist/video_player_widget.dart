import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/services/api_service.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool needsAuth; // true إذا الرابط خلف حماية (Bearer)

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.needsAuth = true,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _vp;
  ChewieController? _chewie;
  bool _loading = true;
  String? _err;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
  try {
    Map<String, String> headers = {}; // << non-null

    if (widget.needsAuth) {
      final token = await ApiService().getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        headers['Accept'] = '*/*';
      }
    }

    final url = Uri.parse(widget.videoUrl);

    _vp = headers.isEmpty
        ? VideoPlayerController.networkUrl(url) // لا تمرر httpHeaders
        : VideoPlayerController.networkUrl(url, httpHeaders: headers);

    await _vp!.initialize();
    _chewie = ChewieController(videoPlayerController: _vp!);
  } catch (e) {
    _err = 'تعذر تشغيل الفيديو: $e';
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}

  @override
  void dispose() {
    _chewie?.dispose();
    _vp?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator(color: blue)),
      );
    }

    if (_err != null || _vp == null || !_vp!.value.isInitialized) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: white,
          border: Border.all(color: grey300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(_err ?? 'تعذر تشغيل الفيديو'),
      );
    }

    final ratio = _vp!.value.aspectRatio == 0 ? 16 / 9 : _vp!.value.aspectRatio;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: ratio,
        child: Chewie(controller: _chewie!),
      ),
    );
  }
}
