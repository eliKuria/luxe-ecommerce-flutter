import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luxe/core/theme/app_theme.dart';
import 'package:luxe/core/utils/currency_formatter.dart';
import 'package:luxe/features/catalog/presentation/providers/product_providers.dart';
import 'package:luxe/features/catalog/presentation/providers/product_detail_state.dart';
import 'package:luxe/features/cart/presentation/providers/cart_providers.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailScreen({required this.productId, super.key});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}
class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool _showStepper = false;

  @override
  Widget build(BuildContext context) {
    final productId = widget.productId;
    final productAsync = ref.watch(productDetailProvider(productId));
    final selectedColor = ref.watch(selectedColorProvider(productId));
    final selectedSize = ref.watch(selectedSizeProvider(productId));
    final quantity = ref.watch(productQuantityProvider(productId));


    return Scaffold(
      body: productAsync.when(
        data: (product) {
          return CustomScrollView(
            slivers: [
              // Image Header
              SliverAppBar(
                expandedHeight: 360,
                pinned: true,
                backgroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 20),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border, size: 20),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: product.images.isNotEmpty
                      ? PageView.builder(
                          itemCount: product.images.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              product.images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFF5F5F5),
                                child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 48, color: AppTheme.secondaryText)),
                              ),
                            );
                          },
                        )
                      : Image.network(
                          product.displayImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFF5F5F5),
                            child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 48, color: AppTheme.secondaryText)),
                          ),
                        ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + Collection
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (product.collection != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                product.collection!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Price & Rating row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            formatKES(product.price),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.star_rounded, size: 18, color: AppTheme.accentColor),
                          const SizedBox(width: 4),
                          Text(
                            '${product.rating}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${product.reviewCount})',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Colors
                      if (product.colors.isNotEmpty) ...[
                        const Text(
                          'COLORS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.secondaryText,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: product.colors.map((color) {
                            final isSelected = selectedColor == color;
                            return GestureDetector(
                              onTap: () {
                                ref.read(selectedColorProvider(productId).notifier).state =
                                    isSelected ? null : color;
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.secondaryAction : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? AppTheme.secondaryAction : AppTheme.dividerColor,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  color,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : AppTheme.primaryText,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Sizes
                      if (product.sizes.isNotEmpty) ...[
                        const Text(
                          'SIZES',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.secondaryText,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: product.sizes.map((size) {
                            final isSelected = selectedSize == size;
                            return GestureDetector(
                              onTap: () {
                                ref.read(selectedSizeProvider(productId).notifier).state =
                                    isSelected ? null : size;
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.secondaryAction : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? AppTheme.secondaryAction : AppTheme.dividerColor,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  size,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : AppTheme.primaryText,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],

                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        'DESCRIPTION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondaryText,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Stock indicator
                      Row(
                        children: [
                          Icon(
                            product.inStock ? Icons.check_circle : Icons.cancel,
                            size: 18,
                            color: product.inStock ? const Color(0xFF4CAF50) : AppTheme.errorColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            product.inStock ? 'In Stock (${product.stock} available)' : 'Out of Stock',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: product.inStock ? const Color(0xFF4CAF50) : AppTheme.errorColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.secondaryText),
              const SizedBox(height: 16),
              const Text('Could not load product'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(productDetailProvider(productId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: productAsync.when(
        data: (product) => Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            height: 54,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: _showStepper
                  // ── Stepper (replaces button after first add) ──────────────
                  ? Row(
                      key: const ValueKey('stepper'),
                      children: [
                        // Minus
                        _orangeStepperBtn(
                          icon: Icons.remove,
                          enabled: quantity > 1,
                          onTap: () {
                            if (quantity > 1) {
                              ref.read(productQuantityProvider(productId).notifier).state--;
                              // Update cart quantity in real-time
                              ref.read(cartProvider.notifier).addToCart(
                                product.id,
                                quantity: quantity - 1,
                              );
                            }
                          },
                        ),
                        // Count
                        Expanded(
                          child: Text(
                            '$quantity',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryText,
                            ),
                          ),
                        ),
                        // Plus
                        _orangeStepperBtn(
                          icon: Icons.add,
                          enabled: quantity < product.stock,
                          onTap: () {
                            if (quantity < product.stock) {
                              ref.read(productQuantityProvider(productId).notifier).state++;
                              // Update cart quantity in real-time
                              ref.read(cartProvider.notifier).addToCart(
                                product.id,
                                quantity: quantity + 1,
                              );
                            }
                          },
                        ),
                      ],
                    )
                  // ── Initial Add to Cart button ─────────────────────────────
                  : SizedBox(
                      key: const ValueKey('add-btn'),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: product.inStock
                            ? () {
                                ref.read(cartProvider.notifier).addToCart(
                                  product.id,
                                  quantity: quantity,
                                );
                                setState(() => _showStepper = true);
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${quantity > 1 ? '$quantity × ' : ''}${product.name} added to cart',
                                    ),
                                    backgroundColor: AppTheme.secondaryAction,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          product.inStock ? 'Add to Cart' : 'Out of Stock',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  /// Orange-filled stepper button (shown after item is added to cart)
  Widget _orangeStepperBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 56,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppTheme.primaryColor : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}
