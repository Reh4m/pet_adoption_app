import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PetImageGallery extends StatefulWidget {
  final List<String> imageUrls;

  const PetImageGallery({super.key, required this.imageUrls});

  @override
  State<PetImageGallery> createState() => _PetImageGalleryState();
}

class _PetImageGalleryState extends State<PetImageGallery> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openFullScreenGallery(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => _FullScreenGallery(
              imageUrls: widget.imageUrls,
              initialIndex: initialIndex,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.imageUrls.isEmpty) {
      return _buildPlaceholder();
    }

    return Stack(
      children: [
        InkWell(
          onTap: () => _openFullScreenGallery(_currentIndex),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return _buildImage(theme, widget.imageUrls[index]);
            },
          ),
        ),
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _buildPageIndicators(),
          ),
      ],
    );
  }

  Widget _buildImage(ThemeData theme, String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder:
          (context, url) => Container(
            color: theme.colorScheme.primary.withAlpha(20),
            child: const Center(child: CircularProgressIndicator()),
          ),
      errorWidget:
          (context, url, error) => Container(
            color: theme.colorScheme.primary.withAlpha(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 5),
                Text(
                  'Error al cargar imagen',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 80, color: Colors.grey.shade500),
          const SizedBox(height: 16),
          Text(
            'Sin imágenes disponibles',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.imageUrls.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color:
                index == _currentIndex
                    ? Colors.white
                    : Colors.white.withAlpha(100),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _FullScreenGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _FullScreenGallery({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${_currentIndex + 1} de ${widget.imageUrls.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implementar descarga de imagen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Descarga próximamente')),
              );
            },
          ),
        ],
      ),
      body: PhotoViewGallery.builder(
        pageController: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider(widget.imageUrls[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(tag: 'pet_image_$index'),
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}
