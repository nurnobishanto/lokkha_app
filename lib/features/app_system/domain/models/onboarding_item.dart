class OnboardingItem {
  final int index;
  final String imagePath;
  final String titlePrefix;
  final String highlightTitle;
  final String titleSuffix;
  final String subtitle;

  const OnboardingItem({
    required this.index,
    required this.imagePath,
    this.titlePrefix = '',
    this.highlightTitle = '',
    this.titleSuffix = '',
    required this.subtitle,
  });

  String get fullTitle => '$titlePrefix$highlightTitle$titleSuffix'.trim();
}
