import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wilson_crepe/features/home/domain/entities/category_entity.dart';
import 'package:wilson_crepe/features/home/domain/entities/crepe_type_price_entity.dart';
import 'package:wilson_crepe/features/home/domain/entities/product_entity.dart';
import 'package:wilson_crepe/features/home/domain/repositories/favorite_repository.dart';
import '../../../domain/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository homeRepository;
  final FavoriteRepository favoritesRepository;
  bool _extrasLoaded = false;

  HomeCubit({required this.homeRepository, required this.favoritesRepository})
    : super(const HomeState());

  Future<void> getHomeData() async {
    if (isClosed) return;

    emit(state.copyWith(status: HomeStatus.loading, clearError: true));

    try {
      final results = await Future.wait([
        homeRepository.getCategories(),
        homeRepository.getProducts(),
        homeRepository.getCrepeTypePrices(),
        favoritesRepository.getFavoriteProductIds(),
      ]);

      if (isClosed) return;

      emit(
        state.copyWith(
          status: HomeStatus.success,
          categories: results[0] as List<CategoryEntity>,
          products: results[1] as List<ProductEntity>,
          crepeTypePrices: results[2] as List<CrepeTypePriceEntity>,
          favoriteProductIds: Set<String>.from(results[3] as List<String>),
        ),
      );
      loadExtras();
    } catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: _errorMessage(e),
        ),
      );
    }
  }

  Future<void> loadExtras() async {
    if (_extrasLoaded) return;

    try {
      final extras = await homeRepository.getExtras();
      _extrasLoaded = true;

      if (!isClosed) emit(state.copyWith(extras: extras));
    } catch (_) {}
  }

  Future<void> selectCategory(String categoryId) async {
    if (isClosed) return;

    emit(
      state.copyWith(
        status: HomeStatus.loading,
        selectedCategoryId: categoryId,
        searchQuery: '',
        clearError: true,
      ),
    );

    try {
      final products = await homeRepository.getProductsByCategory(categoryId);

      if (isClosed) return;

      emit(state.copyWith(status: HomeStatus.success, products: products));
    } catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: _errorMessage(e),
        ),
      );
    }
  }

  Future<void> clearCategory() async {
    if (isClosed) return;

    emit(
      state.copyWith(
        status: HomeStatus.loading,
        clearSelectedCategory: true,
        searchQuery: '',
        clearError: true,
      ),
    );

    try {
      final products = await homeRepository.getProducts();

      if (isClosed) return;

      emit(state.copyWith(status: HomeStatus.success, products: products));
    } catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: _errorMessage(e),
        ),
      );
    }
  }

  Future<void> toggleFavorite(String productId) async {
    if (isClosed) return;

    final wasFavorite = state.isFavorite(productId);
    final updated = Set<String>.from(state.favoriteProductIds);

    if (wasFavorite) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }

    emit(state.copyWith(favoriteProductIds: updated));

    try {
      if (wasFavorite) {
        await favoritesRepository.removeFavorite(productId);
      } else {
        await favoritesRepository.addFavorite(productId);
      }
    } catch (e) {
      if (isClosed) return;

      final reverted = Set<String>.from(state.favoriteProductIds);

      if (wasFavorite) {
        reverted.add(productId);
      } else {
        reverted.remove(productId);
      }

      emit(
        state.copyWith(
          favoriteProductIds: reverted,
          errorMessage: _errorMessage(e),
        ),
      );
    }
  }

  bool isFavorite(String productId) {
    return state.isFavorite(productId);
  }

  void searchProducts(String query) {
    if (isClosed) return;

    emit(state.copyWith(searchQuery: query));
  }

  void clearSearch() {
    if (isClosed) return;

    emit(state.copyWith(searchQuery: ''));
  }

  void clearError() {
    if (isClosed) return;

    emit(state.copyWith(clearError: true));
  }

  Future<void> clearFavorites() async {
    if (isClosed) return;

    final previousFavorites = Set<String>.from(state.favoriteProductIds);

    emit(state.copyWith(favoriteProductIds: const {}));

    try {
      await favoritesRepository.clearFavorites();
    } catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          favoriteProductIds: previousFavorites,
          errorMessage: _errorMessage(e),
        ),
      );
    }
  }

  String _errorMessage(Object error) {
    final message = '${error.runtimeType} $error'.toLowerCase();

    const networkKeywords = [
      'socketexception',
      'handshakeexception',
      'clientexception',
      'timeoutexception',
      'retryable',
      'certificate_verify_failed',
      'failed host lookup',
      'network',
      'connection',
      'timed out',
      'timeout',
    ];

    if (networkKeywords.any(message.contains)) {
      return 'error.network_error'.tr();
    }

    const authKeywords = [
      'jwt expired',
      'session expired',
      'refresh token',
      'not authenticated',
      'unauthorized',
    ];

    if (authKeywords.any(message.contains)) {
      return 'error.session_expired'.tr();
    }

    if (message.contains('permission denied') ||
        message.contains('forbidden')) {
      return 'error.permission_denied'.tr();
    }

    if (message.contains('duplicate key') ||
        message.contains('already exists') ||
        message.contains('duplicate')) {
      return 'error.duplicate_data'.tr();
    }

    if (message.contains('foreign key') ||
        message.contains('violates foreign key constraint')) {
      return 'error.related_data_exists'.tr();
    }

    return 'error.general_error'.tr();
  }
}