import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/theme/theme_extensions.dart';
import 'package:lokkha/features/packages/presentation/views/payment_webview.dart';
import 'package:lokkha/features/profile/data/models/order_v1_model.dart';
import 'package:lokkha/shared/widgets/custom_app_bar.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import '../controllers/orders_details_controller.dart';

class OrderDetailsScreen extends StatelessWidget {
  final dynamic orderId;
  final String? url;

  const OrderDetailsScreen({
    super.key,
    this.orderId,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    final OrdersDetailsController controller =
        Get.isRegistered<OrdersDetailsController>()
            ? Get.find<OrdersDetailsController>()
            : Get.put(OrdersDetailsController());

    // Trigger fetch on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchOrdersDetails(id: orderId, url: url);
    });

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: const CustomAppBar(title: 'অর্ডার ইনফরমেশন'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.apiCallStatus.value == ApiCallStatus.error ||
            controller.orderDetail.value == null) {
          return _buildErrorState(context, controller);
        }

        final order = controller.orderDetail.value!;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Order Status & Invoice Header Card
                _buildInvoiceHeaderCard(context, order),
                const SizedBox(height: 16),

                // 2. Purchased Item & Price Summary Card
                _buildOrderSummaryCard(context, order),
                const SizedBox(height: 16),

                // 3. Customer / Billing Details Card (if present)
                if (order.billingDetails != null &&
                    order.billingDetails!.hasContent) ...[
                  _buildBillingDetailsCard(context, order.billingDetails!),
                  const SizedBox(height: 16),
                ],

                // 4. Payment History & Transactions Card
                _buildPaymentHistoryCard(context, order),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
      // Sticky bottom pay button if order is pending and has payment url
      bottomNavigationBar: Obx(() {
        final order = controller.orderDetail.value;
        if (order != null &&
            !order.isPaid &&
            order.status == 'pending' &&
            order.activePaymentUrl != null) {
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardColor,
                border: Border(
                  top: BorderSide(color: context.borderColor, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => PaymentWebView(url: order.activePaymentUrl!));
                  },
                  icon: const Icon(Icons.payment_rounded, size: 20),
                  label: const Text(
                    'এখনই পেমেন্ট সম্পন্ন করুন',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  /// 1. Invoice & Status Card
  Widget _buildInvoiceHeaderCard(BuildContext context, OrderDetailV1Data order) {
    final statusColor = order.status == 'paid'
        ? const Color(0xFF10B981)
        : order.status == 'pending'
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    final statusIcon = order.status == 'paid'
        ? Icons.check_circle_rounded
        : order.status == 'pending'
            ? Icons.hourglass_top_rounded
            : Icons.cancel_rounded;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invoice No & Copy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ইনভয়েস নম্বর',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '#${order.invoiceNo}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: order.invoiceNo));
                          CustomSnackBar.showCustomToast(
                            message: "ইনভয়েস নম্বর কপি করা হয়েছে",
                          );
                        },
                        child: Icon(
                          Icons.copy_rounded,
                          size: 15,
                          color: context.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Status Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 5),
                    Text(
                      order.statusBengali,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. Purchased Item & Pricing Breakdown Card
  Widget _buildOrderSummaryCard(
      BuildContext context, OrderDetailV1Data order) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ক্রয়কৃত আইটেম",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Item Title and Type
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.primaryLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.layers_rounded,
                  color: context.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.itemTitle.isNotEmpty
                          ? order.itemTitle
                          : 'সাবস্ক্রিপশন প্যাকেজ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    if (order.itemType.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        order.itemType,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: context.borderColor, height: 1),
          const SizedBox(height: 14),

          // Financial Breakdown
          _buildSummaryRow(
            context,
            label: "সাবটোটাল",
            value: order.formattedSubtotal,
            labelColor: context.textSecondary,
          ),
          if (order.discount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              label: order.coupon != null && (order.coupon!.code?.isNotEmpty ?? false)
                  ? "ডিসকাউন্ট (${order.coupon!.code})"
                  : "ডিসকাউন্ট",
              value: "- ${order.formattedDiscount}",
              valueColor: const Color(0xFF10B981),
            ),
          ],
          if (order.coupon != null && (order.coupon!.code?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.local_offer_rounded,
                  size: 14,
                  color: context.primaryColor,
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.primaryLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'কুপন কোড: ${order.coupon!.code}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: context.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Divider(color: context.borderColor, height: 1),
          const SizedBox(height: 14),

          // Net Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "সর্বমোট প্রদেয়",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              Text(
                order.formattedTotal,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Payment Status Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: order.isPaid
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "পরিশোধের অবস্থা",
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
                  ),
                ),
                Text(
                  order.isPaid ? "পরিশোধিত" : "বকেয়া",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: order.isPaid
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Customer / Billing Details Card
  Widget _buildBillingDetailsCard(
      BuildContext context, OrderBillingDetails billing) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline_rounded,
                  size: 18, color: context.primaryColor),
              const SizedBox(width: 8),
              Text(
                "বিলিং ইনফরমেশন",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (billing.name != null && billing.name!.isNotEmpty)
            _buildDetailItem(
              context,
              icon: Icons.person_outline_rounded,
              label: "নাম",
              value: billing.name!,
            ),
          if (billing.phone != null && billing.phone!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDetailItem(
              context,
              icon: Icons.phone_outlined,
              label: "ফোন নম্বর",
              value: billing.phone!,
            ),
          ],
          if (billing.email != null && billing.email!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDetailItem(
              context,
              icon: Icons.email_outlined,
              label: "ইমেইল",
              value: billing.email!,
            ),
          ],
        ],
      ),
    );
  }

  /// 4. Payment History & Transaction Records
  Widget _buildPaymentHistoryCard(
      BuildContext context, OrderDetailV1Data order) {
    final payments = order.payments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "পেমেন্ট হিস্ট্রি",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (payments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor, width: 1),
            ),
            child: Center(
              child: Text(
                "কোনো পেমেন্ট তথ্য পাওয়া যায়নি",
                style: TextStyle(
                  color: context.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final payment = payments[index];
              final statusColor = payment.status == 'paid'
                  ? const Color(0xFF10B981)
                  : payment.status == 'pending'
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFEF4444);

              return Container(
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.borderColor, width: 1),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top: Transaction ID and Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              payment.transactionId != null &&
                                      payment.transactionId!.isNotEmpty
                                  ? '#${payment.transactionId}'
                                  : 'আইডি: #${payment.id ?? '-'}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: context.textPrimary,
                                fontFamily: 'monospace',
                              ),
                            ),
                            if (payment.transactionId != null &&
                                payment.transactionId!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: payment.transactionId!));
                                  CustomSnackBar.showCustomToast(
                                    message: "ট্রানজেকশন আইডি কপি করা হয়েছে",
                                  );
                                },
                                child: Icon(
                                  Icons.copy_rounded,
                                  size: 13,
                                  color: context.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            payment.statusBengali,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Amount & Payment Gateway
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          payment.formattedAmount,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        if (payment.method != null &&
                            payment.method!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: context.surfaceSubtle,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              payment.method!.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Pay Now Button (if pending payment URL exists)
                    if (payment.status == 'pending' &&
                        payment.paymentUrl != null &&
                        payment.paymentUrl!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.to(() => PaymentWebView(url: payment.paymentUrl!));
                          },
                          icon: const Icon(Icons.payment, size: 16),
                          label: const Text(
                            'পেমেন্ট করুন',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? labelColor,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: labelColor ?? context.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? context.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.textMuted),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(
            fontSize: 13,
            color: context.textMuted,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(
      BuildContext context, OrdersDetailsController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: context.dangerColor),
            const SizedBox(height: 12),
            Text(
              "অর্ডার বিবরণ লোড করতে সমস্যা হয়েছে",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  controller.fetchOrdersDetails(id: orderId, url: url),
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
