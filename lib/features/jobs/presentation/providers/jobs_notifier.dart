import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/jobs/data/models/job_list_model.dart';

class JobsState {
  final bool isLoading;
  final JobListModel model;
  final int currentPage;
  final String search;

  JobsState({
    this.isLoading = true,
    JobListModel? model,
    this.currentPage = 1,
    this.search = "",
  }) : model = model ?? JobListModel();

  JobsState copyWith({
    bool? isLoading,
    JobListModel? model,
    int? currentPage,
    String? search,
  }) {
    return JobsState(
      isLoading: isLoading ?? this.isLoading,
      model: model ?? this.model,
      currentPage: currentPage ?? this.currentPage,
      search: search ?? this.search,
    );
  }
}

class JobsNotifier extends Notifier<JobsState> {
  final RestClient _client;

  JobsNotifier({RestClient? client}) : _client = client ?? RestClient();

  @override
  JobsState build() {
    Future.microtask(() => fetchJobs(""));
    return JobsState();
  }

  Future<void> fetchJobs(String search,
      {int page = 1, bool refresh = false}) async {
    if (refresh) {
      MyGetStorage.removeCache(MyGetStorage.jobKey);
    }
    if (!refresh && MyGetStorage.getStorage.hasData(MyGetStorage.jobKey)) {
      var cacheData = MyGetStorage.readCache(MyGetStorage.jobKey);
      if (cacheData != null) {
        state = state.copyWith(
          model: JobListModel.fromJson(cacheData),
          isLoading: false,
        );
      }
    }

    state = state.copyWith(isLoading: true, search: search);
    String url = "${AppConstants.jobsList}?search=$search&page=$page";

    try {
      final response = await _client.get(url);
      if (response.data["status"] == true) {
        JobListModel modelData = JobListModel.fromJson(response.data);
        MyGetStorage.writeCacheData(MyGetStorage.jobKey, response.data);

        if (page > 1 && state.model.jobs != null) {
          final existing = List<Job>.from(state.model.jobs?.data ?? []);
          existing.addAll(modelData.jobs?.data ?? []);
          final updatedJobs = state.model.jobs?.copyWith(data: existing);
          state = state.copyWith(
            model: state.model.copyWith(jobs: updatedJobs),
            currentPage: page,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            model: modelData,
            currentPage: page,
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (error) {
      debugPrint("Error fetching jobs: $error");
      state = state.copyWith(isLoading: false);
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
  final RestClient _client;

  JobDetailsNotifier(this.jobId, {RestClient? client})
      : _client = client ?? RestClient();

  @override
  JobDetailsState build() {
    Future.microtask(fetchSingleJob);
    return const JobDetailsState();
  }

  Future<void> fetchSingleJob() async {
    state = state.copyWith(isLoading: true, error: null);
    String url = "${AppConstants.job}/$jobId";

    try {
      final response = await _client.get(url);
      if (response.data["status"] == true) {
        Job modelData = Job.fromJson(response.data['job']);
        state = state.copyWith(
          job: modelData,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data["message"]?.toString() ?? "Error",
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
