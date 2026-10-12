import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/utils/date_formatter.dart';
import 'package:lokkha/app/router/router.dart';
import '../providers/jobs_notifier.dart';

class JobsView extends ConsumerWidget {
  const JobsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(jobsNotifierProvider);
    final notifier = ref.read(jobsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          "সর্বশেষ নিয়োগ বিজ্ঞপ্তি",
          style: AppTextStyles.heading4.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.00),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    state.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : (state.model.jobs?.data?.isEmpty ?? true)
                            ? const Center(
                                child: Text('তথ্য পাওয়া যায়নি'),
                              )
                            : Expanded(
                                child: ListView.separated(
                                  itemCount:
                                      (state.model.jobs?.data?.length ?? 0) + 1,
                                  shrinkWrap: true,
                                  itemBuilder: (_, index) {
                                    final dataList =
                                        state.model.jobs?.data ?? [];
                                    if (index == dataList.length) {
                                      final lastPage =
                                          state.model.jobs?.lastPage ?? 1;
                                      return (lastPage > state.currentPage)
                                          ? Column(
                                              children: [
                                                const SizedBox(height: 5.0),
                                                GestureDetector(
                                                  onTap: () {
                                                    notifier.fetchJobs(
                                                      "",
                                                      page:
                                                          state.currentPage + 1,
                                                    );
                                                  },
                                                  child: Container(
                                                    height: 30,
                                                    width: MediaQuery.sizeOf(
                                                                context)
                                                            .width /
                                                        2,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                      border: Border.all(
                                                        color: LightThemeColors
                                                            .primaryColor,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: const Center(
                                                      child: Text(
                                                        'আরও দেখুন',
                                                        style: TextStyle(
                                                          color:
                                                              LightThemeColors
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const SizedBox.shrink();
                                    }

                                    var data = dataList[index];
                                    final jobTitle = (data.title != null &&
                                            data.title!.trim().isNotEmpty)
                                        ? data.title!.trim()
                                        : (data.companyName?.trim().isNotEmpty ==
                                                true
                                            ? data.companyName!.trim()
                                            : "");
                                    return GovJobCard(
                                      title: jobTitle,
                                      onTap: () {
                                        debugPrint("1x. ${data.id}");
                                        context.pushNamed(
                                          Routes.jobDetails,
                                          extra: data.id,
                                        );
                                      },
                                      deadline: data.deadline,
                                    );
                                  },
                                  separatorBuilder: (x, i) =>
                                      const SizedBox(height: 5.0),
                                ),
                              ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String displayDeadline(DateTime? deadline) {
  if (deadline == null) {
    return 'unknown';
  }
  return DateFormatter.formatJobDeadline(deadline);
}

class GovJobCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final DateTime? deadline;

  const GovJobCard({
    super.key,
    required this.title,
    required this.onTap,
    this.deadline,
  });

  @override
  Widget build(BuildContext context) {
    final isDeadlineOver =
        deadline != null && DateTime.now().isAfter(deadline!);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: isDeadlineOver
              ? (context.isDark ? const Color(0xFFF43F5E) : Colors.red)
              : context.borderColor,
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: AppTextStyles.heading5.copyWith(color: context.textPrimary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          "আবেদনের শেষ তারিখ: ${displayDeadline(deadline)}",
          style: TextStyle(
            color: isDeadlineOver
                ? (context.isDark
                    ? const Color(0xFFFDA4AF)
                    : Colors.red.shade700)
                : context.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: context.textSecondary,
        ),
      ),
    );
  }
}
