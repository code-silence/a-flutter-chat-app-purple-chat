import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ImageViewerScreen extends StatefulWidget {
  final String imageUrl;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  bool _saving = false;
  bool _sharing = false;

  Future<File> _downloadImage() async {
    final response = await http.get(Uri.parse(widget.imageUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to download image.');
    }

    final directory = await getTemporaryDirectory();

    final file = File(
      '${directory.path}/purplechat_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await file.writeAsBytes(response.bodyBytes);

    return file;
  }

  Future<void> _saveImage() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      var hasAccess = await Gal.hasAccess();

      if (!hasAccess) {
        hasAccess = await Gal.requestAccess();
      }

      if (!hasAccess) {
        throw Exception('Gallery permission denied.');
      }

      final file = await _downloadImage();

      await Gal.putImage(file.path);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image saved to gallery.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save image.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _shareImage() async {
    if (_sharing) return;

    setState(() {
      _sharing = true;
    });

    try {
      final file = await _downloadImage();

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(file.path),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not share image.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sharing = false;
        });
      }
    }
  }

  void _showImageMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.download_rounded),
                title: const Text('Save image'),
                onTap: () {
                  Navigator.pop(context);
                  _saveImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_rounded),
                title: const Text('Share image'),
                onTap: () {
                  Navigator.pop(context);
                  _shareImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.close_rounded),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Save image',
            onPressed: _saving ? null : _saveImage,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download_rounded),
          ),
          IconButton(
            tooltip: 'Share image',
            onPressed: _sharing ? null : _shareImage,
            icon: const Icon(Icons.share_rounded),
          ),
        ],
      ),
      body: GestureDetector(
        onLongPress: _showImageMenu,
        child: Center(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            panEnabled: true,
            scaleEnabled: true,
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              },
              errorWidget: (context, url, error) {
                return const Center(
                  child: Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white,
                    size: 60,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}