import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/shared/widgets/custom_app_bar.dart';
import 'package:lokkha/core/theme/theme_extensions.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/utils/date_formatter.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import '../controllers/my_orders_controller.dart';
import 'order_details_view.dart';

class MyOrdersView extends GetView<MyOrdersController> {
  const MyOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final MyOrdersController controller = Get.put(MyOrdersController());
    return Scaffold(
      appBar: const CustomAppBar(title: 'অর্ডারস হিস্ট্রি'),
      body: Obx(
        () => SafeArea(
          child: RefreshIndicator(
            onRefresh: () => controller.fetchMyOrders(refresh: true),
            child: switch (controller.apiCallStatus.value) {
              ApiCallStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              ApiCallStatus.error => Center(
                  child: Text(
                    "অর্ডার লোড করতে সমস্যা হয়েছে",
                    style: TextStyle(color: context.textPrimary),
                  ),
                ),
              ApiCallStatus.success => controller.model.value.orders!.isEmpty
                  ? Center(
                      child: Text(
                        "কোনো অর্ডার পাওয়া যায়নি",
                        style: TextStyle(color: context.textPrimary),
                      ),
                    )
                  : ListView.builder(
                      itemCount: controller.model.value.orders?.length ?? 0,
                      itemBuilder: (context, index) {
                        final data = controller.model.value.orders![index];
                        return InkWell(
                          onTap: () => Get.off(() => OrderDetailsScreen(
                              url:
                                  "${AppConstants.myOrderDetails}/${data.id!.toInt()}")),
                          child: OrderCard(
                            orderId: "#${data.invoiceNo}",
                            date: data.createdAt!,
                            status: data.status ?? '',
                            totalAmount: '${data.total}',
                            paymentMethod: data.paymentMethod ?? '',
                          ),
                        );
                      },
                    ),
              _ => Center(
                  child: Text(
                    "কোনো অর্ডার পাওয়া যায়নি",
                    style: TextStyle(color: context.textPrimary),
                  ),
                ),
            },
          ),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.orderId,
    required this.date,
    required this.status,
    required this.totalAmount,
    required this.paymentMethod,
  });

  final String orderId;
  final DateTime date;
  final String status;
  final String totalAmount;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(orderId,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: context.textPrimary)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: status == 'pending'
                        ? Colors.amber
                        : status == 'paid'
                            ? Colors.green
                            : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.capitalize.toString(),
                    style: TextStyle(
                      color: status == 'pending' ? Colors.black : Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "তারিখ: ",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary),
                  ),
                  TextSpan(
                    text: DateFormatter.formatToDMY(date),
                    style: TextStyle(fontSize: 15.0, color: context.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2.0),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "মোট: ",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary),
                  ),
                  TextSpan(
                    text: totalAmount,
                    style: TextStyle(fontSize: 15.0, color: context.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2.0),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "পেমেন্ট মেথড: ",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary),
                  ),
                  TextSpan(
                    text: paymentMethod.tr,
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: context.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
