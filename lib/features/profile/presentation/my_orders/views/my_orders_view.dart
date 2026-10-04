import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/theme/theme_extensions.dart';
import 'package:lokkha/features/profile/data/models/order_v1_model.dart';
import 'package:lokkha/shared/widgets/custom_app_bar.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import '../controllers/my_orders_controller.dart';
import 'order_details_view.dart';

class MyOrdersView extends GetView<MyOrdersController> {
  const MyOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    final MyOrdersController controller = Get.isRegistered<MyOrdersController>()
        ? Get.find<MyOrdersController>()
        : Get.put(MyOrdersController());

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: const CustomAppBar(title: 'অর্ডারস হিস্ট্রি'),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter Header
            _buildSearchAndFilters(context, controller),

            // Orders List
            Expanded(
              child: Obx(() {
                final status = controller.apiCallStatus.value;

                if (status == ApiCallStatus.loading && controller.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (status == ApiCallStatus.error && controller.orders.isEmpty) {
                  return _buildErrorState(context, controller);
                }

                if (controller.orders.isEmpty) {
                  return _buildEmptyState(context, controller);
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchOrders(refresh: true),
                  child: ListView.separated(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: controller.orders.length +
                        (controller.hasMore.value ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == controller.orders.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final order = controller.orders[index];
                      return OrderCardV1(
                        order: order,
                        onTap: () {
                          Get.to(() => OrderDetailsScreen(orderId: order.id));
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Search bar and category filter chips
  Widget _buildSearchAndFilters(
      BuildContext context, MyOrdersController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: context.scaffoldColor,
        border: Border(
          bottom: BorderSide(
            color: context.borderColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.borderColor,
                width: 1,
              ),
            ),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'ইনভয়েস বা ট্রানজেকশন আইডি দিয়ে খুঁজুন...',
                hintStyle: TextStyle(
                  color: context.textMuted,
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: context.textMuted,
                  size: 20,
                ),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: context.textMuted,
                        size: 18,
                      ),
                      onPressed: controller.clearSearch,
                    );
                  }
                  return const SizedBox.shrink();
                }),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Status Filter Badges Row
          Obx(() {
            final counts = controller.filterCounts.value;
            final currentStatus = controller.selectedStatus.value;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _FilterChipBadge(
                    label: 'সব',
                    count: counts.all,
                    isSelected: currentStatus == 'all',
                    onTap: () => controller.setStatusFilter('all'),
                    activeColor: context.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  _FilterChipBadge(
                    label: 'পরিশোধিত',
                    count: counts.paid,
                    isSelected: currentStatus == 'paid',
                    onTap: () => controller.setStatusFilter('paid'),
                    activeColor: const Color(0xFF10B981),
                    badgeBgColor: const Color(0xFF059669),
                  ),
                  const SizedBox(width: 8),
                  _FilterChipBadge(
                    label: 'অপেক্ষমাণ',
                    count: counts.pending,
                    isSelected: currentStatus == 'pending',
                    onTap: () => controller.setStatusFilter('pending'),
                    activeColor: const Color(0xFFF59E0B),
                    badgeBgColor: const Color(0xFFD97706),
                  ),
                  const SizedBox(width: 8),
                  _FilterChipBadge(
                    label: 'ব্যর্থ',
                    count: counts.failed,
                    isSelected: currentStatus == 'failed',
                    onTap: () => controller.setStatusFilter('failed'),
                    activeColor: const Color(0xFFEF4444),
                    badgeBgColor: const Color(0xFFDC2626),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),

          // Model Type Filter Badges Row
          Obx(() {
            final counts = controller.filterCounts.value;
            final currentType = controller.selectedModelType.value;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _TypeFilterChip(
                    label: 'সব আইটেম',
                    isSelected: currentType == 'all',
                    onTap: () => controller.setModelTypeFilter('all'),
                  ),
                  const SizedBox(width: 8),
                  _TypeFilterChip(
                    label: 'প্যাকেজ',
                    count: counts.package,
                    isSelected: currentType == 'Package',
                    onTap: () => controller.setModelTypeFilter('Package'),
                  ),
                  const SizedBox(width: 8),
                  _TypeFilterChip(
                    label: 'কোর্স',
                    count: counts.course,
                    isSelected: currentType == 'Course',
                    onTap: () => controller.setModelTypeFilter('Course'),
                  ),
                  const SizedBox(width: 8),
                  _TypeFilterChip(
                    label: 'মডেল টেস্ট',
                    count: counts.exam,
                    isSelected: currentType == 'Exam',
                    onTap: () => controller.setModelTypeFilter('Exam'),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, MyOrdersController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.primaryLight.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 56,
                color: context.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "কোনো অর্ডার পাওয়া যায়নি",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.searchQuery.value.isNotEmpty ||
                      controller.selectedStatus.value != 'all' ||
                      controller.selectedModelType.value != 'all'
                  ? "নির্বাচিত ফিল্টারের সাথে মিলে এমন কোনো অর্ডার নেই।"
                  : "আপনার অ্যাকাউন্টে এখনও কোনো অর্ডার সম্পন্ন হয়নি।",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: context.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            if (controller.searchQuery.value.isNotEmpty ||
                controller.selectedStatus.value != 'all' ||
                controller.selectedModelType.value != 'all')
              ElevatedButton.icon(
                onPressed: () {
                  controller.searchController.clear();
                  controller.searchQuery.value = '';
                  controller.selectedStatus.value = 'all';
                  controller.selectedModelType.value = 'all';
                  controller.fetchOrders(refresh: true);
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('সব ফিল্টার মুছুন'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, MyOrdersController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: context.dangerColor),
            const SizedBox(height: 12),
            Text(
              "অর্ডার লোড করতে সমস্যা হয়েছে",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "ইন্টারনেট সংযোগ চেক করে পুনরায় চেষ্টা করুন",
              style: TextStyle(fontSize: 13, color: context.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.fetchOrders(refresh: true),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('পুনরায় চেষ্টা করুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter chip with badge counter
class _FilterChipBadge extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color? badgeBgColor;

  const _FilterChipBadge({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    this.badgeBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : context.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : context.borderColor,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : context.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? (badgeBgColor ?? Colors.black.withValues(alpha: 0.25))
                    : context.borderColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : context.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Model Type Filter Chip
class _TypeFilterChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeFilterChip({
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? context.textPrimary
              : context.surfaceSubtle,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? context.textPrimary : context.borderColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? (context.isDark ? Colors.black : Colors.white)
                    : context.textMuted,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 4),
              Text(
                '($count)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? (context.isDark ? Colors.black : Colors.white)
                      : context.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Redesigned Order Card UI for V1 API
class OrderCardV1 extends StatelessWidget {
  final OrderV1Item order;
  final VoidCallback onTap;

  const OrderCardV1({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = order.status == 'paid'
        ? const Color(0xFF10B981)
        : order.status == 'pending'
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Invoice Number & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '#${order.invoiceNo}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: context.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: order.invoiceNo));
                        CustomSnackBar.showCustomToast(
                          message: "ইনভয়েস নম্বর কপি করা হয়েছে",
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: context.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        order.statusBengali,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Item Title
            Text(
              order.itemTitle.isNotEmpty ? order.itemTitle : 'প্যাকেজ সাবস্ক্রিপশন',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Type Badge & Transaction ID (if available)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (order.itemType.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.surfaceSubtle,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.itemType,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                if (order.isTrial)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.infoColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ট্রায়াল',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: context.infoColor,
                      ),
                    ),
                  ),
                if (order.transactionId.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tag_rounded, size: 12, color: context.textMuted),
                      Text(
                        order.transactionId,
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textMuted,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Divider
            Divider(
              height: 1,
              color: context.borderColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 10),

            // Footer: Date, Payment Method & Total Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date & Method
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: context.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          order.formattedDateOnly.isNotEmpty
                              ? order.formattedDateOnly
                              : (order.createdAt ?? ''),
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (order.paymentMethod.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.payment_rounded,
                            size: 13,
                            color: context.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            order.paymentMethod.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: context.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

                // Price & Detail Arrow
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (order.discount > 0)
                          Text(
                            '৳ ${order.subtotal.toInt()}',
                            style: TextStyle(
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                              color: context.textMuted,
                            ),
                          ),
                        Text(
                          order.formattedTotal,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: context.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.surfaceSubtle,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
