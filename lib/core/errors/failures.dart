abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'সার্ভারে সমস্যা হয়েছে। দয়া করে আবার চেষ্টা করুন।', super.statusCode]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'ইন্টারনেট সংযোগ পাওয়া যায়নি। আপনার নেটওয়ার্ক পরীক্ষা করুন।', super.statusCode]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'লোকাল ডেটা লোড করতে সমস্যা হয়েছে।', super.statusCode]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'অথেনটিকেশন ব্যর্থ হয়েছে।', super.statusCode]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'প্রদত্ত তথ্য সঠিক নয়।', super.statusCode]);
}
