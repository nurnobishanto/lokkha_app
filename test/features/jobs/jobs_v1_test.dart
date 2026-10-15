import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/features/jobs/jobs.dart';

const Map<String, dynamic> sampleV1JobsListJson = {
  "success": true,
  "message": "Job circulars retrieved successfully.",
  "data": {
    "items": [
      {
        "id": 139,
        "title": "কর কমিশনারের কার্যালয়, কর অঞ্চল-৩, ঢাকা জেলা নিয়োগ বিজ্ঞপ্তি",
        "slug": "item-1-2",
        "image_url": null,
        "department_id": 70,
        "department_name": "কর কমিশনারের কার্যালয়, কর অঞ্চল-৩, ঢাকা জেলা নিয়োগ বিজ্ঞপ্তি",
        "deadline": "2026-11-01",
        "vacancy": "15",
        "created_at": "2026-10-12"
      },
      {
        "id": 138,
        "title": "বাংলাদেশ পর্যটন করপোরেশন নিয়োগ বিজ্ঞপ্তি",
        "slug": "item-1-1",
        "image_url": "https://lokkha.com/uploads/jobs/sample.jpg",
        "department_id": 69,
        "department_name": "বাংলাদেশ পর্যটন করপোরেশন",
        "deadline": "2026-10-27",
        "vacancy": null,
        "created_at": "2026-09-28"
      },
      {
        "id": 137,
        "title": "কর কমিশনারের কার্যালয় কর অঞ্চল-১ নিয়োগ বিজ্ঞপ্তি ২০২৬",
        "slug": "item-1",
        "image_url": null,
        "department_id": 68,
        "department_name": "Recent Job Circular September 2026",
        "deadline": "2026-10-14",
        "vacancy": null,
        "created_at": "2026-09-23"
      }
    ]
  },
  "meta": {
    "current_page": 1,
    "last_page": 7,
    "per_page": 20,
    "total": 136,
    "from": 1,
    "to": 20,
    "has_more": true
  }
};

const Map<String, dynamic> sampleV1JobDetailJson = {
  "success": true,
  "message": "Job circular retrieved successfully.",
  "data": {
    "id": 139,
    "title": "কর কমিশনারের কার্যালয়, কর অঞ্চল-৩, ঢাকা জেলা নিয়োগ বিজ্ঞপ্তি",
    "slug": "item-1-2",
    "image_url": null,
    "department_id": 70,
    "department_name": "কর কমিশনারের কার্যালয়, কর অঞ্চল-৩, ঢাকা জেলা নিয়োগ বিজ্ঞপ্তি",
    "deadline": "2026-11-01",
    "vacancy": "12",
    "created_at": "2026-10-12",
    "description": "আবেদনের বিস্তারিত বিবরণ ও শর্তাবলীসমূহ।",
    "application_link": "https://taxeszone3dhaka.gov.bd",
    "age_limit": "১৮-৩০ বছর",
    "salary": "১১,০০০-২৬,৫৯০ টাকা"
  }
};

const List<Map<String, dynamic>> sampleV1DepartmentsJson = [
  {
    "id": 56,
    "name": "Anti-Corruption Commission (ACC)",
    "slug": "anti-corruption-commission-acc"
  },
  {
    "id": 31,
    "name": "Bangladesh Bank",
    "slug": "bangladesh-bank"
  }
];

class FakeJobsRepository implements JobsRepository {
  final JobListModel jobsModel;
  final Job? jobDetail;
  final List<JobDepartment> departments;

  FakeJobsRepository({
    required this.jobsModel,
    this.jobDetail,
    this.departments = const [],
  });

  @override
  Future<JobListModel> getJobs({
    int page = 1,
    int perPage = 20,
    int? departmentId,
    String? search,
  }) async {
    return jobsModel;
  }

  @override
  Future<Job?> getJobDetail(dynamic id) async {
    return jobDetail;
  }

  @override
  Future<List<JobDepartment>> getDepartments() async {
    return departments;
  }
}

class FakeJobsNotifier extends JobsNotifier {
  final JobsState initialState;
  FakeJobsNotifier(this.initialState, {JobsRepository? repo})
      : super(repository: repo);

  @override
  JobsState build() {
    return initialState;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('V1 Jobs Model Parsing Tests', () {
    test('JobListModel correctly parses V1 envelope with items & meta', () {
      final model = JobListModel.fromJson(sampleV1JobsListJson);

      expect(model.success, true);
      expect(model.status, true);
      expect(model.message, 'Job circulars retrieved successfully.');
      expect(model.jobs?.data?.length, 3);
      expect(model.jobs?.currentPage, 1);
      expect(model.jobs?.lastPage, 7);
      expect(model.jobs?.total, 136);
      expect(model.jobs?.hasMore, true);

      final firstJob = model.jobs!.data!.first;
      expect(firstJob.id, 139);
      expect(firstJob.title, 'কর কমিশনারের কার্যালয়, কর অঞ্চল-৩, ঢাকা জেলা নিয়োগ বিজ্ঞপ্তি');
      expect(firstJob.departmentId, 70);
      expect(firstJob.departmentName, 'কর কমিশনারের কার্যালয়, কর অঞ্চল-৩, ঢাকা জেলা নিয়োগ বিজ্ঞপ্তি');
      expect(firstJob.companyName, 'কর কমিশনারের কার্যালয়, কর অঞ্চল-৩, ঢাকা জেলা নিয়োগ বিজ্ঞপ্তি');
      expect(firstJob.vacancy, '15');
      expect(firstJob.deadline, isNotNull);
      expect(firstJob.createdAt, isNotNull);
    });

    test('Job detail parses all V1 fields cleanly', () {
      final dataMap = sampleV1JobDetailJson['data'] as Map<String, dynamic>;
      final job = Job.fromJson(dataMap);

      expect(job.id, 139);
      expect(job.title, 'কর কমিশনারের কার্যালয়, কর অঞ্চল-৩, ঢাকা জেলা নিয়োগ বিজ্ঞপ্তি');
      expect(job.departmentId, 70);
      expect(job.departmentName, 'কর কমিশনারের কার্যালয়, কর অঞ্চল-৩, ঢাকা জেলা নিয়োগ বিজ্ঞপ্তি');
      expect(job.companyName, 'কর কমিশনারের কার্যালয়, কর অঞ্চল-৩, ঢাকা জেলা নিয়োগ বিজ্ঞপ্তি');
      expect(job.vacancy, '12');
      expect(job.description, 'আবেদনের বিস্তারিত বিবরণ ও শর্তাবলীসমূহ।');
      expect(job.details, 'আবেদনের বিস্তারিত বিবরণ ও শর্তাবলীসমূহ।');
      expect(job.applicationLink, 'https://taxeszone3dhaka.gov.bd');
      expect(job.source, 'https://taxeszone3dhaka.gov.bd');
      expect(job.ageLimit, '১৮-৩০ বছর');
      expect(job.salary, '১১,০০০-২৬,৫৯০ টাকা');
    });

    test('JobDepartment parses departments correctly', () {
      final dept = JobDepartment.fromJson(sampleV1DepartmentsJson.first);

      expect(dept.id, 56);
      expect(dept.name, 'Anti-Corruption Commission (ACC)');
      expect(dept.slug, 'anti-corruption-commission-acc');
    });
  });

  group('JobsNotifier Filtering & Search Tests', () {
    test('Client-side search filters jobs by title and department accurately', () {
      final model = JobListModel.fromJson(sampleV1JobsListJson);
      final rawJobs = model.jobs?.data ?? [];
      final repo = FakeJobsRepository(jobsModel: model);

      final container = ProviderContainer(
        overrides: [
          jobsRepositoryProvider.overrideWithValue(repo),
          jobsNotifierProvider.overrideWith(
            () => FakeJobsNotifier(
              JobsState(
                isLoading: false,
                model: model,
                filteredJobs: rawJobs,
              ),
              repo: repo,
            ),
          ),
        ],
      );

      final notifier = container.read(jobsNotifierProvider.notifier);

      // Search 'পর্যটন'
      notifier.searchJobs('পর্যটন');
      expect(container.read(jobsNotifierProvider).filteredJobs.length, 1);
      expect(container.read(jobsNotifierProvider).filteredJobs.first.id, 138);

      // Search 'কর কমিশনার'
      notifier.searchJobs('কর কমিশনার');
      expect(container.read(jobsNotifierProvider).filteredJobs.length, 2);

      // Reset search
      notifier.searchJobs('');
      expect(container.read(jobsNotifierProvider).filteredJobs.length, 3);
    });
  });

  group('JobsView UI Widget Tests', () {
    testWidgets('JobsView renders title, list of jobs and see more button', (tester) async {
      final model = JobListModel.fromJson(sampleV1JobsListJson);
      final repo = FakeJobsRepository(jobsModel: model);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => ProviderScope(
            overrides: [
              jobsRepositoryProvider.overrideWithValue(repo),
              jobsNotifierProvider.overrideWith(
                () => FakeJobsNotifier(
                  JobsState(
                    isLoading: false,
                    model: model,
                    currentPage: 1,
                  ),
                  repo: repo,
                ),
              ),
            ],
            child: const MaterialApp(
              home: JobsView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify AppBar title
      expect(find.text("সর্বশেষ নিয়োগ বিজ্ঞপ্তি"), findsOneWidget);

      // Verify Job cards
      expect(find.text('কর কমিশনারের কার্যালয়, কর অঞ্চল-৩, ঢাকা জেলা নিয়োগ বিজ্ঞপ্তি'), findsOneWidget);
      expect(find.text('বাংলাদেশ পর্যটন করপোরেশন নিয়োগ বিজ্ঞপ্তি'), findsOneWidget);
      expect(find.text('কর কমিশনারের কার্যালয় কর অঞ্চল-১ নিয়োগ বিজ্ঞপ্তি ২০২৬'), findsOneWidget);

      // Verify 'আরও দেখুন' button (lastPage 7 > currentPage 1)
      expect(find.text('আরও দেখুন'), findsOneWidget);
    });
  });

  group('JobDetailsScreen UI Widget Tests', () {
    testWidgets('JobDetailsScreen renders complete job info and action button', (tester) async {
      final job = Job.fromJson(sampleV1JobDetailJson['data'] as Map<String, dynamic>);
      final model = JobListModel.fromJson(sampleV1JobsListJson);
      final repo = FakeJobsRepository(jobsModel: model, jobDetail: job);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => ProviderScope(
            overrides: [
              jobsRepositoryProvider.overrideWithValue(repo),
              jobDetailsNotifierProvider(139).overrideWith(
                () => JobDetailsNotifier(139, repository: repo),
              ),
            ],
            child: const MaterialApp(
              home: JobDetailsScreen(id: 139),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify AppBar
      expect(find.text("চাকরির বিস্তারিত"), findsOneWidget);

      // Verify Job Title
      expect(find.text('কর কমিশনারের কার্যালয়, কর অঞ্চল-৩, ঢাকা জেলা নিয়োগ বিজ্ঞপ্তি'), findsOneWidget);

      // Verify description
      expect(find.text("আবেদনের বিস্তারিত বিবরণ ও শর্তাবলীসমূহ।"), findsOneWidget);

      // Verify vacancy, salary, age limit
      expect(find.text("পদসংখ্যা: 12"), findsOneWidget);
      expect(find.text("বেতন: ১১,০০০-২৬,৫৯০ টাকা"), findsOneWidget);
      expect(find.text("বয়সসীমা: ১৮-৩০ বছর"), findsOneWidget);

      // Verify Apply Button
      expect(find.text("আবেদন করুন"), findsOneWidget);
    });
  });
}
