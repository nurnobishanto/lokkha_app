import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/shared/widgets/custom_action_button.dart';
import 'package:lokkha/shared/widgets/custom_app_bar.dart';
import 'package:lokkha/core/theme/theme_extensions.dart';
import 'package:lokkha/core/utils/date_formatter.dart';
import 'package:lokkha/features/packages/packages.dart';
import '../controllers/orders_details_controller.dart';

class OrderDetailsScreen extends GetView<OrdersDetailsController> {
  final String url;
  const OrderDetailsScreen({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(OrdersDetailsController());
    controller.fetchOrdersDetails(url: url);

    return Scaffold(
      appBar: const CustomAppBar(title: 'অর্ডার ইনফরমেশন'),
      body: Obx(() {
        final model = controller.model.value;
        return controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "#${model.order?.invoiceNo ?? ''}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: context.textPrimary),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                DateFormatter.formatToDMY(
                                    model.order!.createdAt!),
                                style: TextStyle(
                                    color: context.textSecondary, fontSize: 14),
                              ),
                              const SizedBox(height: 10),
                              ProductItem(
                                name: () {
                                  return model.order!.displayName.toString();
                                }(),
                                price: () {
                                  if (model.order!.modelType.toString() ==
                                      'App\\Models\\Package') {
                                    return '৳ ${model.order!.package?.discountedPrice?.toString() ?? '0'}';
                                  } else if (model.order!.modelType
                                          .toString() ==
                                      'App\\Models\\Course') {
                                    return '৳ ${model.order!.course?.salePrice?.toString() ?? '0'}';
                                  } else {
                                    return '৳ ${model.order!.package?.discountedPrice?.toString() ?? '0'}';
                                  }
                                }(),
                              ),
                              const SizedBox(height: 10),
                              const Divider(),
                              OrderSummaryItem(
                                label: "মোট",
                                amount: '৳ ${model.order!.total ?? ''}',
                              ),
                              (model.order!.status.toString() == 'paid')
                                    ? OrderSummaryItem(
                                        label: "পরিশোধ",
                                        amount:
                                            '৳ ${model.order!.total.toString()}',
                                      )
                                    : const SizedBox(),
                              (model.order!.status.toString() != 'paid')
                                    ? OrderSummaryItem(
                                        label: "বকেয়া",
                                        amount:
                                            '৳ ${model.order!.total.toString()}',
                                        isNegative: true,
                                      )
                                    : const SizedBox(),
                              const SizedBox(height: 10),
                              const Divider(),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  OrderStatusLabel(
                                    status: model.order!.status
                                        .toString()
                                        .toUpperCase(),
                                    color: model.order!.status == 'pending'
                                        ? Colors.amber
                                        : model.order!.status == 'paid'
                                            ? Colors.green
                                            : Colors.red,
                                    fontColor: model.order!.status == 'pending'
                                        ? Colors.black
                                        : model.order!.status == 'paid'
                                            ? Colors.white
                                            : Colors.white,
                                  ),
                                  OrderStatusLabel(
                                    status:
                                        model.order!.paymentMethod!.toString(),
                                    color: context.isDark ? Colors.grey.shade800 : Colors.black,
                                    fontColor: Colors.white,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      //
                      Text(
                        "পেমেন্ট হিস্ট্রি",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      SizedBox(
                        height: model.order!.payments!.length * 100,
                        child: ListView.builder(
                            itemCount: model.order!.payments!.length,
                            itemBuilder: (_, index) {
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "#${model.order!.payments![index].transactionId.toString()}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: context.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 10.0),
                                            Text(
                                              "৳ ${model.order!.payments![index].amount.toString()}",
                                              style: TextStyle(color: context.textPrimary),
                                            ),
                                            Text(
                                              " ${model.order!.payments![index].paymentMethod!.toString()}",
                                              style: TextStyle(color: context.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            OrderStatusLabel(
                                              status: model.order!
                                                  .payments![index].status!
                                                  .toString()
                                                  .toUpperCase(),
                                              color: model
                                                          .order!
                                                          .payments![index]
                                                          .status ==
                                                      'pending'
                                                  ? Colors.amber
                                                  : model
                                                              .order!
                                                              .payments![index]
                                                              .status ==
                                                          'paid'
                                                      ? Colors.green
                                                      : Colors.red,
                                              fontColor: model
                                                          .order!
                                                          .payments![index]
                                                          .status ==
                                                      'pending'
                                                  ? Colors.black
                                                  : model
                                                              .order!
                                                              .payments![index]
                                                              .status ==
                                                          'paid'
                                                      ? Colors.white
                                                      : Colors.white,
                                            ),
                                            model.order!.payments![index]
                                                        .status ==
                                                    'pending'
                                                ? Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8.0.h),
                                                    child: SizedBox(
                                                      width: 100,
                                                      height: 30,
                                                      child: CustomActionButton(
                                                        text: 'পেমেন্ট করুন',
                                                        onPressed: () {
                                                          Get.to(PaymentWebView(
                                                              url: model
                                                                  .order!
                                                                  .payments![
                                                                      index]
                                                                  .paymentUrl
                                                                  .toString()));
                                                        },
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              );
      }),
    );
  }
}

class ProductItem extends StatelessWidget {
  final String name;
  final String price;

  const ProductItem({super.key, required this.name, required this.price});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontSize: 14, color: context.textPrimary),
            ),
          ),
          Text(
            price,
            style: TextStyle(fontSize: 14, color: context.textPrimary),
          ),
        ],
      ),
    );
  }
}

class OrderSummaryItem extends StatelessWidget {
  final String label;
  final String amount;
  final bool isBold;
  final bool isNegative;

  const OrderSummaryItem({
    super.key,
    required this.label,
    required this.amount,
    this.isBold = false,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: context.textPrimary,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isNegative ? Colors.red : context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderStatusLabel extends StatelessWidget {
  final String status;
  final Color color;
  final Color fontColor;

  const OrderStatusLabel(
      {super.key,
      required this.status,
      required this.color,
      required this.fontColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: fontColor, fontSize: 12),
      ),
    );
  }
}
