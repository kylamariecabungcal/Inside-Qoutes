import 'package:flutter/material.dart';
import 'app_settings.dart';
import 'services/rest_api_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    final favorites = await RestApiService.instance.getFavorites();
    if (mounted) {
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.of(context);
    final isTagalog = settings.isTagalog;
    final isDark = settings.isDark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF001A4D);
    final backgroundColor =
        isDark ? const Color(0xFF050816) : const Color(0xFFF2F6FF);
    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          isTagalog ? 'Mga Paborito' : 'Favorites',
          style: TextStyle(color: primaryTextColor),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: primaryTextColor,
                ),
              )
            : _favorites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: primaryTextColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isTagalog
                              ? 'Walang mga paborito pa'
                              : 'No favorites yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: primaryTextColor.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isTagalog
                              ? 'Mag-save ng mga paborito para makita dito'
                              : 'Save favorites to see them here',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: primaryTextColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final favorite = _favorites[index];
                      final type = favorite['type'] as String? ?? 'quote';
                      final content = favorite['content'] as String? ?? '';
                      final reference = favorite['reference'] as String?;
                      final favoriteId = favorite['id'] as String? ?? '';

                      return Card(
                        color: cardColor,
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Icon(
                            type == 'verse'
                                ? Icons.menu_book
                                : Icons.format_quote,
                            color: const Color(0xFF005BEA),
                          ),
                          title: Text(
                            content,
                            style: TextStyle(
                              color: primaryTextColor,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: reference != null
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    reference,
                                    style: TextStyle(
                                      color: primaryTextColor.withOpacity(0.6),
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red,
                            onPressed: () {
                              _showDeleteDialog(context, favoriteId, isTagalog);
                            },
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, String favoriteId, bool isTagalog) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isTagalog ? 'Tanggalin ang Paborito' : 'Remove Favorite'),
        content: Text(
          isTagalog
              ? 'Sigurado ka bang gusto mong tanggalin ito?'
              : 'Are you sure you want to remove this favorite?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(isTagalog ? 'Kanselahin' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Attempt to remove the favorite on the server.
              final success =
                  await RestApiService.instance.removeFavorite(favoriteId);
              Navigator.of(context).pop();

              if (success) {
                // Optimistically update the local list so the UI updates immediately.
                if (mounted) {
                  setState(() {
                    _favorites
                        .removeWhere((f) => (f['id'] as String?) == favoriteId);
                  });
                }
              } else {
                // If delete failed, reload from server to ensure UI consistency and show message.
                _loadFavorites();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isTagalog
                          ? 'Hindi natanggal ang paborito. Subukang muli.'
                          : 'Failed to remove favorite. Please try again.'),
                    ),
                  );
                }
              }
            },
            child: Text(
              isTagalog ? 'Tanggalin' : 'Remove',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
