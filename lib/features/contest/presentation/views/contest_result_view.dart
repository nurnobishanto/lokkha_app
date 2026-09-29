import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lokkha/core/core.dart';

import 'package:lokkha/shared/models/contest_result.dart';
import 'package:lokkha/features/auth/auth.dart';

class ContestResultView extends StatefulWidget {
  final List<ContestResult> contestResults;

  const ContestResultView({super.key, required this.contestResults});

  @override
  State<ContestResultView> createState() => _ContestResultViewState();
}

class _ContestResultViewState extends State<ContestResultView> {
  List<ContestResult>? filteredResults;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredResults = widget.contestResults;
    debugPrint('contestResults: ${widget.contestResults[0].positiveMark}');
    debugPrint('filteredResults: ${filteredResults![0].positiveMark}');
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredResults = widget.contestResults.where((result) {
        final name = result.user?.name?.toLowerCase() ?? '';
        final userId = result.user?.userId?.toString().toLowerCase() ?? '';
        return name.contains(searchQuery) || userId.contains(searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn.value != true
        ? const AuthGatewayView()
        : Scaffold(
            appBar: AppBar(title: const Text("প্রতিযোগিতার র‍্যাঙ্ক")),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: updateSearch,
                    decoration: InputDecoration(
                      hintText: 'নাম বা আইডি দিয়ে খুঁজুন...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                /// 📄 রেজাল্ট লিস্ট
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredResults?.length ?? 0,
                    itemBuilder: (context, index) {
                      final result = filteredResults![index];
                      debugPrint("my mark: ${result.contest}");
                      final originalIndex =
                          widget.contestResults.indexOf(result);
                      final user = result.user;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 6),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: buildAvatar(user!),
                                  title: Text(
                                    user.name ?? 'নাম নেই',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                      'আইডি: ${user.userId ?? 'আইডি নেই'}'),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'র‍্যাংক #${originalIndex + 1}',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 6),

                                /// সময়কাল
                                Row(
                                  children: [
                                    const Icon(Icons.timer,
                                        size: 20, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(
                                      result.completeDuration != null
                                          ? 'সময়: ${result.completeDuration! ~/ 60} মিনিট ${result.completeDuration! % 60} সেকেন্ড'
                                          : 'সময়: পাওয়া যায়নি',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                /// সাবমিট টাইম
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 20, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(
                                      result.updatedAt.isNotEmpty
                                          ? 'সাবমিট: ${DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(result.updatedAt))}'
                                          : 'সাবমিট টাইম পাওয়া যায়নি',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                /// সঠিক ও ভুল উত্তর
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '✅ সঠিক উত্তর: ${result.correctAnswers}'),
                                    Text(
                                        '❌ ভুল উত্তর: ${result.incorrectAnswers}'),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                /// মোট নম্বর
                                Row(
                                  children: [
                                    const Icon(Icons.stars,
                                        size: 20, color: Colors.amber),
                                    const SizedBox(width: 6),
                                    Text(
                                      'মোট নম্বর: ${calculateTotalMarks(result)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }
}

double calculateTotalMarks(ContestResult result) {
  final correct = result.correctAnswers ?? 0;
  final incorrect = result.incorrectAnswers ?? 0;
  final positive = result.positiveMark ?? 0;
  final negative = result.negativeMark ?? 0;

  return (correct * positive) - (incorrect * negative);
}
