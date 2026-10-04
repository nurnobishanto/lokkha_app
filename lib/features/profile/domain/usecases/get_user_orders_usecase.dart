import '../../data/models/order_v1_model.dart';
import '../repositories/profile_repository.dart';

class GetUserOrdersUseCase {
  final ProfileRepository repository;

  GetUserOrdersUseCase({ProfileRepository? repository})
      : repository = repository ?? ProfileRepository();

  Future<OrderV1ListResponse> call({
    String status = 'all',
    String modelType = 'all',
    String paymentMethod = 'all',
    String? search,
    int page = 1,
    int perPage = 10,
  }) {
    return repository.getUserOrders(
      status: status,
      modelType: modelType,
      paymentMethod: paymentMethod,
      search: search,
      page: page,
      perPage: perPage,
    );
  }
}
