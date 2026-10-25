import 'package:wilson_crepe/features/home/data/datasources/favorite_remote_data_source.dart';
import 'package:wilson_crepe/features/home/domain/repositories/favorite_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteRemoteDataSource remoteDataSource;

  FavoriteRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<String>> getFavoriteProductIds() async {
    return await remoteDataSource.getFavoriteProductIds();
  }

  @override
  Future<void> addFavorite(String productId) async {
    await remoteDataSource.addFavorite(productId);
  }

  @override
  Future<void> removeFavorite(String productId) async {
    await remoteDataSource.removeFavorite(productId);
  }

  @override
  Future<void> clearFavorites() async {
    await remoteDataSource.clearFavorites();
  }
}