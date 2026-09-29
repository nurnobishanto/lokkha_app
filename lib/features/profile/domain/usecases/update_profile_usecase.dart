import 'dart:io';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase({required this.repository});

  Future<Map<String, dynamic>> call({
    required String name,
    String? email,
    String? gender,
    String? dateOfBirth,
    String? occupation,
    String? organization,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    File? photoFile,
  }) {
    return repository.updateProfile(
      name: name,
      email: email,
      gender: gender,
      dateOfBirth: dateOfBirth,
      occupation: occupation,
      organization: organization,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      state: state,
      zipCode: zipCode,
      country: country,
      photoFile: photoFile,
    );
  }
}
