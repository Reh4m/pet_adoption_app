import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/presentation/utils/image_picker_service.dart';
import 'package:video_player/video_player.dart';

class MediaPreviewScreen extends StatefulWidget {
  final File file;
  final MediaType mediaType;

  const MediaPreviewScreen({
    super.key,
    required this.file,
    required this.mediaType,
  });

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  final _captionController = TextEditingController();
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.mediaType == MediaType.video) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.file(widget.file);
    await _videoController!.initialize();
    setState(() {
      _isVideoInitialized = true;
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _handleSend() {
    Navigator.pop(context, {
      'file': widget.file,
      'caption': _captionController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_getTitle(), style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(child: Center(child: _buildPreview(theme))),
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _captionController,
                      decoration: InputDecoration(
                        hintText: 'Agregar comentario...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    radius: 24,
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: theme.colorScheme.onPrimary,
                      ),
                      onPressed: _handleSend,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (widget.mediaType) {
      case MediaType.image:
        return 'Enviar foto';
      case MediaType.video:
        return 'Enviar video';
    }
  }

  Widget _buildPreview(ThemeData theme) {
    switch (widget.mediaType) {
      case MediaType.image:
        return InteractiveViewer(
          child: Image.file(widget.file, fit: BoxFit.contain),
        );

      case MediaType.video:
        if (!_isVideoInitialized || _videoController == null) {
          return const CircularProgressIndicator(color: Colors.white);
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            IconButton(
              icon: Icon(
                _videoController!.value.isPlaying
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                size: 64,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  if (_videoController!.value.isPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
                });
              },
            ),
          ],
        );
    }
  }
}
