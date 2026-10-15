import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/jobs/data/models/job_list_model.dart';
import 'package:lokkha/features/jobs/data/repositories/jobs_repository.dart';

class JobsState {
  final bool isLoading;
  final bool isLoadingMore;
  final JobListModel model;
  final int currentPage;
  final String search;
  final JobDepartment? selectedDepartment;
  final List<JobDepartment> departments;
  final List<Job> filteredJobs;

  JobsState({
    this.isLoading = true,
    this.isLoadingMore = false,
    JobListModel? model,
    this.currentPage = 1,
    this.search = "",
    this.selectedDepartment,
    this.departments = const [],
    this.filteredJobs = const [],
  }) : model = model ?? JobListModel();

  List<Job> get currentJobs =>
      (search.trim().isNotEmpty || filteredJobs.isNotEmpty)
          ? filteredJobs
          : (model.jobs?.data ?? []);

  JobsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    JobListModel? model,
    int? currentPage,
    String? search,
    JobDepartment? selectedDepartment,
    List<JobDepartment>? departments,
    List<Job>? filteredJobs,
    bool clearDepartment = false,
  }) {
    return JobsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      model: model ?? this.model,
      currentPage: currentPage ?? this.currentPage,
      search: search ?? this.search,
      selectedDepartment: clearDepartment
          ? null
          : (selectedDepartment ?? this.selectedDepartment),
      departments: departments ?? this.departments,
      filteredJobs: filteredJobs ?? this.filteredJobs,
    );
  }
}

class JobsNotifier extends Notifier<JobsState> {
  final JobsRepository? _injectedRepository;

  JobsNotifier({JobsRepository? repository})
      : _injectedRepository = repository;

  JobsRepository get _repo =>
      _injectedRepository ?? ref.read(jobsRepositoryProvider);

  @override
  JobsState build() {
    Future.microtask(() => init());
    return JobsState();
  }

  Future<void> init() async {
    // Check cache first for rapid startup
    if (MyGetStorage.getStorage.hasData(MyGetStorage.jobKey)) {
      final cacheData = MyGetStorage.readCache(MyGetStorage.jobKey);
      if (cacheData != null && cacheData is Map<String, dynamic>) {
        try {
          final cachedModel = JobListModel.fromJson(cacheData);
          if (cachedModel.jobs?.data?.isNotEmpty == true) {
            state = state.copyWith(
              model: cachedModel,
              filteredJobs: cachedModel.jobs?.data ?? [],
              isLoading: false,
            );
          }
        } catch (_) {}
      }
    }

    await Future.wait([
      fetchDepartments(),
      fetchJobs("", page: 1),
    ]);
  }

  Future<void> fetchDepartments() async {
    try {
      final depts = await _repo.getDepartments();
      state = state.copyWith(departments: depts);
    } catch (e) {
      debugPrint("Error fetching departments: $e");
    }
  }

  List<Job> applySearch(List<Job> list, String query) {
    if (query.trim().isEmpty) return list;
    final q = query.trim().toLowerCase();
    return list.where((job) {
      final title = (job.title ?? '').toLowerCase();
      final dept = (job.departmentName ?? '').toLowerCase();
      final comp = (job.companyName ?? '').toLowerCase();
      return title.contains(q) || dept.contains(q) || comp.contains(q);
    }).toList();
  }

  void searchJobs(String query) {
    state = state.copyWith(search: query);
    final all = state.model.jobs?.data ?? [];
    state = state.copyWith(filteredJobs: applySearch(all, query));
  }

  Future<void> filterByDepartment(JobDepartment? dept) async {
    final isSame = state.selectedDepartment?.id == dept?.id;
    final newDept = isSame ? null : dept;
    state = state.copyWith(
      selectedDepartment: newDept,
      clearDepartment: newDept == null,
      currentPage: 1,
    );
    await fetchJobs(state.search, page: 1, refresh: true);
  }

  Future<void> fetchJobs(
    String search, {
    int page = 1,
    bool refresh = false,
  }) async {
    if (refresh) {
      MyGetStorage.removeCache(MyGetStorage.jobKey);
    }

    if (page == 1) {
      state = state.copyWith(isLoading: true, search: search);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final modelData = await _repo.getJobs(
        page: page,
        perPage: 20,
        departmentId: state.selectedDepartment?.id,
        search: search.trim().isNotEmpty ? search.trim() : null,
      );

      if (modelData.success == true || modelData.status == true) {
        if (page == 1) {
          // Cache page 1 data
          MyGetStorage.writeCacheData(MyGetStorage.jobKey, modelData.toJson());
        }

        if (page > 1 && state.model.jobs != null) {
          final existing = List<Job>.from(state.model.jobs?.data ?? []);
          existing.addAll(modelData.jobs?.data ?? []);
          final updatedJobs = state.model.jobs?.copyWith(
            currentPage: page,
            lastPage: modelData.jobs?.lastPage ?? state.model.jobs?.lastPage,
            total: modelData.jobs?.total ?? state.model.jobs?.total,
            hasMore: modelData.jobs?.hasMore ?? false,
            data: existing,
          );

          final newModel = state.model.copyWith(jobs: updatedJobs);
          state = state.copyWith(
            model: newModel,
            currentPage: page,
            filteredJobs: applySearch(existing, state.search),
            isLoading: false,
            isLoadingMore: false,
          );
        } else {
          final items = modelData.jobs?.data ?? [];
          state = state.copyWith(
            model: modelData,
            currentPage: page,
            filteredJobs: applySearch(items, state.search),
            isLoading: false,
            isLoadingMore: false,
          );
        }
      } else {
        state = state.copyWith(isLoading: false, isLoadingMore: false);
      }
    } catch (error) {
      debugPrint("Error fetching jobs: $error");
      state = state.copyWith(isLoading: false, isLoadingMore: false);
    }
  }
}

final jobsNotifierProvider =
    NotifierProvider<JobsNotifier, JobsState>(JobsNotifier.new);

// Single Job Details Notifier
class JobDetailsState {
  final bool isLoading;
  final Job? job;
  final String? error;

  const JobDetailsState({
    this.isLoading = true,
    this.job,
    this.error,
  });

  JobDetailsState copyWith({
    bool? isLoading,
    Job? job,
    String? error,
  }) {
    return JobDetailsState(
      isLoading: isLoading ?? this.isLoading,
      job: job ?? this.job,
      error: error ?? this.error,
    );
  }
}

class JobDetailsNotifier extends Notifier<JobDetailsState> {
  final int jobId;
  final JobsRepository? _injectedRepository;

  JobDetailsNotifier(this.jobId, {JobsRepository? repository})
      : _injectedRepository = repository;

  JobsRepository get _repo =>
      _injectedRepository ?? ref.read(jobsRepositoryProvider);

  @override
  JobDetailsState build() {
    Future.microtask(fetchSingleJob);
    return const JobDetailsState();
  }

  Future<void> fetchSingleJob() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final jobData = await _repo.getJobDetail(jobId);
      if (jobData != null) {
        state = state.copyWith(
          job: jobData,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "তথ্য পাওয়া যায়নি",
        );
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }
}

final jobDetailsNotifierProvider =
    NotifierProvider.family<JobDetailsNotifier, JobDetailsState, int>(
  JobDetailsNotifier.new,
);
