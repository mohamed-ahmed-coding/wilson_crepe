abstract class FavoriteRepository {
  Future<List<String>> getFavoriteProductIds();
  Future<void> addFavorite(String productId);
  Future<void> removeFavorite(String productId);
  Future<void> clearFavorites();
}