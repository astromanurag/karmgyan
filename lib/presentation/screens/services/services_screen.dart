import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_theme.dart';
import '../../../services/enhanced_data_service.dart';
import '../../../services/cart_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/pull_to_refresh_wrapper.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final hasConnection = await ErrorHandler.checkConnectivity();
      if (!hasConnection && mounted) {
        await ErrorHandler.showConnectivityError(context);
      }

      final services = await EnhancedDataService().getServices();
      if (mounted) {
        setState(() {
          _services = services;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = ErrorHandler.getErrorMessage(e);
        });
        ErrorHandler.showError(context, e);
      }
    }
  }

  Future<void> _addToCart(Map<String, dynamic> service) async {
    try {
      await CartService.addToCart(service);
      if (mounted) {
        ErrorHandler.showSuccess(context, 'Added to cart!');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.creamLight,
              Colors.white,
            ],
          ),
        ),
        child: _isLoading
            ? const LoadingWidget(message: 'Loading services...')
            : _error != null
                ? ErrorStateWidget(
                    title: 'Failed to load services',
                    message: _error,
                    onRetry: _loadServices,
                  )
                : _services.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.shopping_bag_outlined,
                        title: 'No services available',
                        message: 'Check back later for new services',
                      )
                    : PullToRefreshWrapper(
                        onRefresh: _loadServices,
                        child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 20),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: InkWell(
                          onTap: () => _addToCart(service),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  AppTheme.accentGold.withOpacity(0.05),
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.accentGold,
                                        AppTheme.accentGoldLight,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accentGold.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.star_rounded,
                                    color: AppTheme.primaryNavy,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service['name'] ?? 'Service',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        service['description'] ?? '',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppTheme.accentGold,
                                                  AppTheme.accentGoldLight,
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '₹${service['price'] ?? '0'}',
                                              style: TextStyle(
                                                color: AppTheme.primaryNavy,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          ElevatedButton.icon(
                                            onPressed: () => _addToCart(service),
                                            icon: const Icon(Icons.shopping_cart, size: 16),
                                            label: const Text('Add to Cart'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.primaryBlue,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                        ),
                      ),
      ),
    );
  }
}

