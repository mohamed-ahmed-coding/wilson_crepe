import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/core/extension/localized_product_extension.dart';
import 'package:wilson_crepe/core/routes/app_routes.dart';
import 'package:wilson_crepe/features/home/data/models/cart_item_model.dart';
import 'package:wilson_crepe/features/home/domain/entities/extra_entity.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/cart/cart_cubit.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/cart/cart_state.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_entity.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_item_entity.dart';
import 'package:wilson_crepe/features/order/presentation/cubit/order_cubit.dart';
import 'package:wilson_crepe/features/order/presentation/cubit/order_state.dart';
import 'package:wilson_crepe/features/order/presentation/widgets/order_summary_card.dart';
import 'package:wilson_crepe/features/order/presentation/widgets/order_text_field.dart';
import 'package:wilson_crepe/features/order/presentation/widgets/place_order_button.dart';
import 'package:wilson_crepe/injection_container.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final notesController = TextEditingController();
  late final OrderCubit _orderCubit;
  List<OrderItemEntity> _submittedItems = const [];

  String get userName {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata;

    final fullName = metadata?['full_name']?.toString().trim();
    final name = metadata?['name']?.toString().trim();

    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }

    if (name != null && name.isNotEmpty) {
      return name;
    }

    return '';
  }

  @override
  void initState() {
    super.initState();
    _orderCubit = sl<OrderCubit>();
    nameController.text = userName;
  }

  @override
  void dispose() {
    _orderCubit.close();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _placeOrder() {
    if (!_formKey.currentState!.validate()) return;

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      _showMessage('order.login_first'.tr(), isError: true);
      return;
    }

    final cartItems = context.read<CartCubit>().state.items;

    if (cartItems.isEmpty) {
      _showMessage('order.empty_cart'.tr(), isError: true);
      return;
    }

    final items = _buildOrderItems(cartItems);

    final totalPrice = items.fold<double>(
      0,
      (sum, item) => sum + item.itemTotal,
    );

    final order = OrderEntity(
      userId: user.id,
      totalPrice: totalPrice,
      status: OrderStatus.pending,
      customerName: nameController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      notes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
    );

    _submittedItems = items;
    _orderCubit.createOrder(order, items);
  }

  List<OrderItemEntity> _buildOrderItems(List<CartItemModel> cartItems) {
    return cartItems.map<OrderItemEntity>((cartItem) {
      final product = cartItem.product;

      final double originalPrice = product.price.toDouble();
      final int discount = product.discountPercentage ?? 0;

      final double discountedPrice = discount > 0
          ? originalPrice * (1 - discount / 100)
          : originalPrice;

      final String? crepeType = cartItem.crepeType;
      final double priceModifier = cartItem.priceModifier.toDouble();

      final List<ExtraEntity> extras = cartItem.extras;
      final double extrasTotal = extras.fold<double>(
        0,
        (sum, e) => sum + e.price,
      );

      final double unitPrice = discountedPrice + priceModifier + extrasTotal;
      final double itemTotal = unitPrice * cartItem.quantity;

      return OrderItemEntity(
        productId: int.parse(product.id.toString()),
        productName: product.localizedName(context),
        productPrice: discountedPrice,
        quantity: cartItem.quantity,
        itemTotal: itemTotal,
        discountPercentage: discount > 0 ? discount : null,
        crepeType: crepeType,
        priceModifier: priceModifier,
        extras: extras,
      );
    }).toList();
  }

  void _onOrderStateChanged(BuildContext context, OrderState state) {
    if (state is OrderCreated) {
      context.read<CartCubit>().clear();

      _showMessage('order.success'.tr());

      GoRouter.of(context).goNamed(
        AppRoutes.orderConfirmedScreen,
        extra: {'order': state.order, 'items': _submittedItems},
      );
    } else if (state is OrderError) {
      _showMessage(state.message, isError: true);
    }
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'order.name_required'.tr();
    }

    if (name.length < 3) {
      return 'order.name_min_length'.tr();
    }

    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return 'order.phone_required'.tr();
    }

    if (!RegExp(r'^(01)[0-9]{9}$').hasMatch(phone)) {
      return 'order.phone_invalid'.tr();
    }

    return null;
  }

  String? _validateAddress(String? value) {
    final address = value?.trim() ?? '';

    if (address.isEmpty) {
      return 'order.address_required'.tr();
    }

    if (address.length < 10) {
      return 'order.address_min_length'.tr();
    }

    return null;
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? AppColors.error.withValues(alpha: 0.8)
              : AppColors.green.withValues(alpha: 0.8),
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message).tr()),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _orderCubit,
      child: BlocListener<OrderCubit, OrderState>(
        listener: _onOrderStateChanged,
        child: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            final isLoading = state is OrderCreating;

            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Wilson_bg_white.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: AppColors.lightBrown.withValues(alpha: 0.1),
                  foregroundColor: AppColors.primaryBrown,
                  shape: Border.symmetric(
                    horizontal: BorderSide(
                      color: AppColors.primaryBrown,
                      width: 2.w,
                    ),
                  ),
                  elevation: 0,
                  title: Text(
                    'order.place_order'.tr(),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                body: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/Wilson_bg_white.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: BlocBuilder<CartCubit, CartState>(
                      builder: (context, cart) {
                        return ListView(
                          padding: EdgeInsets.all(16.w),
                          children: [
                            Text(
                              'order.your_order'.tr(),
                              style: TextStyle(
                                color: AppColors.primaryBrown,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'order.review_details'.tr(),
                              style: TextStyle(
                                color: AppColors.lightBrown,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            OrderSummaryCard(cart: cart),
                            SizedBox(height: 20.h),
                            Text(
                              'order.delivery_information'.tr(),
                              style: TextStyle(
                                color: AppColors.primaryBrown,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            OrderTextField(
                              controller: nameController,
                              label: 'order.name'.tr(),
                              readOnly: true,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              validator: _validateName,
                            ),
                            SizedBox(height: 12.h),
                            OrderTextField(
                              controller: phoneController,
                              label: 'order.phone'.tr(),
                              hint: 'order.phone_hint'.tr(),
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              validator: _validatePhone,
                            ),
                            SizedBox(height: 12.h),
                            OrderTextField(
                              controller: addressController,
                              label: 'order.address'.tr(),
                              hint: 'order.address_hint'.tr(),
                              maxLines: 2,
                              textInputAction: TextInputAction.next,
                              validator: _validateAddress,
                            ),
                            SizedBox(height: 12.h),
                            OrderTextField(
                              controller: notesController,
                              label: 'order.notes'.tr(),
                              hint: 'order.notes_hint'.tr(),
                              maxLines: 3,
                              textInputAction: TextInputAction.done,
                            ),
                            SizedBox(height: 24.h),
                            PlaceOrderButton(
                              isLoading: isLoading,
                              onPressed: cart.isEmpty || isLoading
                                  ? null
                                  : _placeOrder,
                            ),
                            SizedBox(height: 12.h),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}