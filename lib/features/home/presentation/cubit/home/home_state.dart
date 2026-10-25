import 'package:equatable/equatable.dart';
import 'package:wilson_crepe/core/extension/localized_product_extension.dart';
import 'package:wilson_crepe/features/home/domain/entities/category_entity.dart';
import 'package:wilson_crepe/features/home/domain/entities/crepe_type_price_entity.dart';
import 'package:wilson_crepe/features/home/domain/entities/extra_entity.dart';
import 'package:wilson_crepe/features/home/domain/entities/product_entity.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<CategoryEntity> categories;
  final List<ProductEntity> products;
  final List<CrepeTypePriceEntity> crepeTypePrices;
  final Set<String> favoriteProductIds;
  final String? selectedCategoryId;
  final String searchQuery;
  final List<ExtraEntity> extras;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.categories = const [],
    this.products = const [],
    this.crepeTypePrices = const [],
    this.favoriteProductIds = const {},
    this.selectedCategoryId,
    this.searchQuery = '',
    this.extras = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<CategoryEntity>? categories,
    List<ProductEntity>? products,
    List<CrepeTypePriceEntity>? crepeTypePrices,
    Set<String>? favoriteProductIds,
    String? selectedCategoryId,
    String? searchQuery,
    String? errorMessage,
    bool clearSelectedCategory = false,
    List<ExtraEntity>? extras,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      crepeTypePrices: crepeTypePrices ?? this.crepeTypePrices,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      selectedCategoryId: clearSelectedCategory ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      extras: extras ?? this.extras,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get isLoading => status == HomeStatus.loading;
  bool get hasError => status == HomeStatus.failure;
  bool get hasNoData => categories.isEmpty && products.isEmpty;
  bool get isFilteringByCategory => selectedCategoryId != null;
  bool get isSearching => searchQuery.trim().isNotEmpty;

  static String _normalizeSearchText(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ـ', '');
  }

  List<ProductEntity> get searchResults {
    if (!isSearching) return const [];

    final query = _normalizeSearchText(searchQuery);

    return products.where((product) {
      final searchableText = _normalizeSearchText([
        product.localizedName,
        product.localizedDescription,
        product.nameAr,
        product.nameEn,
        product.descriptionAr,
        product.descriptionEn,
      ].join(' '));

      return searchableText.contains(query);
    }).toList();
  }

  bool isFavorite(String productId) => favoriteProductIds.contains(productId);

  CategoryEntity? getCategoryById(String categoryId) {
    for (final category in categories) {
      if (category.id == categoryId) return category;
    }
    return null;
  }

  CrepeTypePriceEntity? getCrepeTypePrice({
    required String categoryId,
    required String type,
  }) {
    for (final price in crepeTypePrices) {
      if (price.categoryId == categoryId && price.type == type) {
        return price;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [
    status,
    categories,
    products,
    crepeTypePrices,
    favoriteProductIds,
    selectedCategoryId,
    searchQuery,
    extras,
    errorMessage,
  ];
}