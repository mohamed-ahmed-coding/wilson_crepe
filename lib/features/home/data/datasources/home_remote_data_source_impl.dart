import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wilson_crepe/core/monitoring/crashlytics_service.dart';
import 'package:wilson_crepe/features/home/data/datasources/home_remote_data_source.dart';
import 'package:wilson_crepe/features/home/data/models/crepe_type_price_model.dart';
import 'package:wilson_crepe/features/home/data/models/extra_model.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient supabase;

  HomeRemoteDataSourceImpl({required this.supabase});

  String get _localizedNameColumn {
    return Intl.getCurrentLocale().startsWith('ar') ? 'name_ar' : 'name_en';
  }

  Future<T> _monitor<T>(String operation, Future<T> Function() action) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      await CrashlyticsService.instance.recordError(
        error,
        stackTrace,
        reason: operation,
      );
      rethrow;
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() {
    return _monitor('Load categories', () async {
      final response = await supabase
          .from('categories')
          .select()
          .eq('type', 'menu')
          .order(_localizedNameColumn);

      return (response as List)
          .map(
            (json) => CategoryModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    });
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    return _monitor('Load products', () async {
      final response = await supabase
          .from('products')
          .select()
          .eq('is_archived', false)
          .order(_localizedNameColumn);

      return (response as List)
          .map((json) => ProductModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    });
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    return _monitor('Load products by category', () async {
      final response = await supabase
          .from('products')
          .select()
          .eq('category_id', categoryId)
          .order(_localizedNameColumn);

      return (response as List)
          .map((json) => ProductModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    });
  }

  @override
  Future<List<CrepeTypePriceModel>> getCrepeTypePrices() async {
    return _monitor('Load crepe type prices', () async {
      final response = await supabase
          .from('crepe_type_prices')
          .select()
          .order('type');

      return (response as List)
          .map(
            (json) =>
                CrepeTypePriceModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    });
  }

  @override
  Future<List<ExtraModel>> getExtras() async {
    return _monitor('Load extras', () async {
      final response = await supabase
          .from('products')
          .select('id, name_en, name_ar, price, categories!inner(type)')
          .eq('categories.type', 'extra')
          .eq('is_available', true)
          .eq('is_archived', false)
          .order('name_en');

      return (response as List)
          .map((json) => ExtraModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    });
  }
}
