import '../../data/models/order_v1_model.dart';
import '../repositories/profile_repository.dart';

class GetOrderDetailsUseCase {
  final ProfileRepository repository;

  GetOrderDetailsUseCase({ProfileRepository? repository})
      : repository = repository ?? ProfileRepository();

  Future<OrderDetailV1Data> call(dynamic id) {
    return repository.getOrderDetails(id);
  }
}
