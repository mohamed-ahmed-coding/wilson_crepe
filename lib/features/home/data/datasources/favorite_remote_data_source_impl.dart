import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wilson_crepe/features/home/data/datasources/favorite_remote_data_source.dart';

class FavoriteRemoteDataSourceImpl
    implements FavoriteRemoteDataSource {
  final SupabaseClient supabase;

  FavoriteRemoteDataSourceImpl({
    required this.supabase,
  });

  @override
  Future<List<String>> getFavoriteProductIds() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final response = await supabase
        .from('favorites')
        .select('product_id')
        .eq('user_id', user.id);

    return (response as List)
        .map(
          (item) => item['product_id'].toString(),
        )
        .toList();
  }

  @override
  Future<void> addFavorite(String productId) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated');
    }

    await supabase.from('favorites').insert({
      'user_id': user.id,
      'product_id': productId,
    });
  }

  @override
  Future<void> removeFavorite(String productId) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated');
    }

    await supabase
        .from('favorites')
        .delete()
        .eq('user_id', user.id)
        .eq('product_id', productId);
  }

  @override
  Future<void> clearFavorites() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated');
    }

    await supabase.from('favorites').delete().eq('user_id', user.id);
  }
}