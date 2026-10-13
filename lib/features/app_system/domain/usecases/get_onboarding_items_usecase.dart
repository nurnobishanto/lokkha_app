import 'package:lokkha/core/constants/app_images.dart';
import '../models/onboarding_item.dart';

class GetOnboardingItemsUseCase {
  const GetOnboardingItemsUseCase();

  List<OnboardingItem> call() {
    return [
      OnboardingItem(
        index: 0,
        imagePath: AssetVectorPaths.onboarding1,
        titlePrefix: 'স্মার্টভাবে ',
        highlightTitle: 'প্রস্তুতি নাও',
        subtitle: 'স্মার্ট ও কার্যকর শেখার টুল ব্যবহার\nকরে প্রতিদিন হাজারো প্রশ্ন অনুশীলন করো।',
      ),
      OnboardingItem(
        index: 1,
        imagePath: AssetVectorPaths.onboarding2,
        titlePrefix: 'তোমার লক্ষ্য অর্জন করো',
        subtitle: 'নিয়মিত থাকো এবং দৃঢ়\nআত্মবিশ্বাস নিয়ে প্রতিটি পরীক্ষায় সফল হও',
      ),
      OnboardingItem(
        index: 2,
        imagePath: AssetVectorPaths.onboarding3,
        titlePrefix: 'তোমার অগ্রগতি ট্র্যাক করো',
        subtitle: 'তোমার দুর্বল দিকগুলো বুঝে\nকার্যকরভাবে উন্নতির জন্য বিস্তারিত বিশ্লেষণ পাও',
      ),
    ];
  }
}
