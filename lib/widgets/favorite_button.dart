import 'package:flutter/material.dart';
import 'package:happy_view/services/favorites_service.dart';

class FavoriteButton extends StatefulWidget {
  final Map<String, dynamic> image;
  final Color? color;
  final double size;
  final void Function(bool isFavorite)? onToggle;

  const FavoriteButton({
    super.key,
    required this.image,
    this.color,
    this.size = 24.0,
    this.onToggle,
  });

  @override
  FavoriteButtonState createState() => FavoriteButtonState();
}

class FavoriteButtonState extends State<FavoriteButton> {
  late FavoritesService _favoritesService;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _favoritesService = FavoritesService();
    _isFavorite = _favoritesService.isFavorite(widget.image['id']);
    
    // Listen for changes from other instances
    _favoritesService.favoritesNotifier.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _favoritesService.favoritesNotifier.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) {
      setState(() {
        _isFavorite = _favoritesService.isFavorite(widget.image['id']);
      });
    }
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image['id'] != widget.image['id']) {
      setState(() {
        _isFavorite = _favoritesService.isFavorite(widget.image['id']);
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final bool newState = await _favoritesService.toggleFavorite(widget.image);
    
    if (widget.onToggle != null) {
      widget.onToggle!(newState);
    }
    
    // Show feedback
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newState ? 'Added to favorites' : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    
    setState(() {
      _isFavorite = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: _isFavorite ? Colors.red : widget.color ?? Colors.white,
        size: widget.size,
      ),
      onPressed: _toggleFavorite,
      tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
    );
  }
}