import 'package:lokkha/features/home/home.dart';
import '../repositories/profile_repository.dart';

class GetDashboardOverviewUseCase {
  final ProfileRepository repository;

  GetDashboardOverviewUseCase({required this.repository});

  Future<DashboardOverviewModel?> call() {
    return repository.getDashboardOverview();
  }
}
