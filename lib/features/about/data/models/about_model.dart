import 'package:lokkha/core/network/endpoints.dart';

/// Root model for /api/v1/about
class AboutResponseModel {
  final bool success;
  final String message;
  final AboutDataModel? data;

  AboutResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory AboutResponseModel.fromJson(Map<String, dynamic> json) {
    return AboutResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? AboutDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AboutDataModel {
  final AboutSeoModel? seo;
  final AboutHeroModel? hero;
  final List<AboutMetricItem> metrics;
  final AboutPillarsModel? pillars;
  final AboutAppShowcaseModel? appShowcase;
  final AboutCommunityAndSupportModel? communityAndSupport;
  final AboutTestimonialsModel? testimonials;
  final AboutCtaModel? cta;

  AboutDataModel({
    this.seo,
    this.hero,
    this.metrics = const [],
    this.pillars,
    this.appShowcase,
    this.communityAndSupport,
    this.testimonials,
    this.cta,
  });

  factory AboutDataModel.fromJson(Map<String, dynamic> json) {
    // Robustly parse metrics: can be null, list, or map
    List<AboutMetricItem> parsedMetrics = [];
    final rawMetrics = json['metrics'];
    if (rawMetrics is List) {
      parsedMetrics = rawMetrics
          .whereType<Map<String, dynamic>>()
          .map((m) => AboutMetricItem.fromJson(m))
          .toList();
    } else if (rawMetrics is Map<String, dynamic>) {
      rawMetrics.forEach((key, val) {
        if (val is Map<String, dynamic>) {
          parsedMetrics.add(AboutMetricItem.fromJson(val));
        } else if (val != null) {
          parsedMetrics.add(AboutMetricItem(
            title: _prettifyMetricKey(key),
            value: val.toString(),
            icon: _guessMetricIcon(key),
          ));
        }
      });
    }

    // If metrics was null or empty, provide default impact counters as specified
    if (parsedMetrics.isEmpty) {
      parsedMetrics = [
        AboutMetricItem(
          title: 'মোট শিক্ষার্থী',
          value: '৫০,০০০+',
          subtitle: 'সারাদেশে সক্রিয়',
          icon: 'school',
        ),
        AboutMetricItem(
          title: 'মডেল টেস্ট',
          value: '১,২০০+',
          subtitle: 'মানসম্মত প্রশ্নব্যাংক',
          icon: 'quiz',
        ),
        AboutMetricItem(
          title: 'সফলতার হার',
          value: '৯৮%',
          subtitle: 'শিক্ষার্থীদের সন্তুষ্টি',
          icon: 'trending_up',
        ),
        AboutMetricItem(
          title: 'হেল্পলাইন সেবা',
          value: '২৪/৭',
          subtitle: 'প্রয়োজনে সার্বক্ষণিক পাশে',
          icon: 'support_agent',
        ),
      ];
    }

    return AboutDataModel(
      seo: json['seo'] is Map<String, dynamic>
          ? AboutSeoModel.fromJson(json['seo'] as Map<String, dynamic>)
          : null,
      hero: json['hero'] is Map<String, dynamic>
          ? AboutHeroModel.fromJson(json['hero'] as Map<String, dynamic>)
          : null,
      metrics: parsedMetrics,
      pillars: json['pillars'] is Map<String, dynamic>
          ? AboutPillarsModel.fromJson(json['pillars'] as Map<String, dynamic>)
          : null,
      appShowcase: json['app_showcase'] is Map<String, dynamic>
          ? AboutAppShowcaseModel.fromJson(
              json['app_showcase'] as Map<String, dynamic>)
          : null,
      communityAndSupport: json['community_and_support'] is Map<String, dynamic>
          ? AboutCommunityAndSupportModel.fromJson(
              json['community_and_support'] as Map<String, dynamic>)
          : null,
      testimonials: json['testimonials'] is Map<String, dynamic>
          ? AboutTestimonialsModel.fromJson(
              json['testimonials'] as Map<String, dynamic>)
          : null,
      cta: json['cta'] is Map<String, dynamic>
          ? AboutCtaModel.fromJson(json['cta'] as Map<String, dynamic>)
          : null,
    );
  }

  static String _prettifyMetricKey(String key) {
    switch (key.toLowerCase()) {
      case 'total_students':
        return 'মোট শিক্ষার্থী';
      case 'model_tests':
        return 'মডেল টেস্ট';
      case 'success_rate':
        return 'সফলতার হার';
      case 'helpline_coverage':
        return 'হেল্পলাইন সেবা';
      default:
        return key.replaceAll('_', ' ');
    }
  }

  static String _guessMetricIcon(String key) {
    switch (key.toLowerCase()) {
      case 'total_students':
        return 'school';
      case 'model_tests':
        return 'quiz';
      case 'success_rate':
        return 'trending_up';
      case 'helpline_coverage':
        return 'support_agent';
      default:
        return 'insights';
    }
  }
}

class AboutSeoModel {
  final String title;
  final String description;
  final List<String> keywords;

  AboutSeoModel({
    this.title = '',
    this.description = '',
    this.keywords = const [],
  });

  factory AboutSeoModel.fromJson(Map<String, dynamic> json) {
    return AboutSeoModel(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      keywords: (json['keywords'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class AboutHeroModel {
  final String tagline;
  final String heading;
  final String subheading;
  final String description1;
  final String description2;
  final String imageUrl;
  final List<String> features;
  final AboutFloatingBadgesModel? floatingBadges;

  AboutHeroModel({
    this.tagline = '',
    this.heading = '',
    this.subheading = '',
    this.description1 = '',
    this.description2 = '',
    this.imageUrl = '',
    this.features = const [],
    this.floatingBadges,
  });

  factory AboutHeroModel.fromJson(Map<String, dynamic> json) {
    return AboutHeroModel(
      tagline: json['tagline']?.toString() ?? '',
      heading: json['heading']?.toString() ?? '',
      subheading: json['subheading']?.toString() ?? '',
      description1: json['description_1']?.toString() ?? '',
      description2: json['description_2']?.toString() ?? '',
      imageUrl: Endpoints.resolveUrl(json['image_url']?.toString()),
      features: (json['features'] as List?)?.map((e) => e.toString()).toList() ?? [],
      floatingBadges: json['floating_badges'] is Map<String, dynamic>
          ? AboutFloatingBadgesModel.fromJson(
              json['floating_badges'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AboutFloatingBadgesModel {
  final AboutFloatingBadgeItem? top;
  final AboutFloatingBadgeItem? bottom;

  AboutFloatingBadgesModel({this.top, this.bottom});

  factory AboutFloatingBadgesModel.fromJson(Map<String, dynamic> json) {
    return AboutFloatingBadgesModel(
      top: json['top'] is Map<String, dynamic>
          ? AboutFloatingBadgeItem.fromJson(json['top'] as Map<String, dynamic>)
          : null,
      bottom: json['bottom'] is Map<String, dynamic>
          ? AboutFloatingBadgeItem.fromJson(
              json['bottom'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AboutFloatingBadgeItem {
  final String title;
  final String subtitle;
  final String number;
  final String label;
  final String icon;

  AboutFloatingBadgeItem({
    this.title = '',
    this.subtitle = '',
    this.number = '',
    this.label = '',
    this.icon = '',
  });

  factory AboutFloatingBadgeItem.fromJson(Map<String, dynamic> json) {
    return AboutFloatingBadgeItem(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
    );
  }

  String get displayTitle => title.isNotEmpty ? title : number;
  String get displaySubtitle => subtitle.isNotEmpty ? subtitle : label;
}

class AboutMetricItem {
  final String title;
  final String value;
  final String subtitle;
  final String icon;

  AboutMetricItem({
    this.title = '',
    this.value = '',
    this.subtitle = '',
    this.icon = '',
  });

  factory AboutMetricItem.fromJson(Map<String, dynamic> json) {
    return AboutMetricItem(
      title: json['title']?.toString() ??
          json['name']?.toString() ??
          json['label']?.toString() ??
          '',
      value: json['value']?.toString() ??
          json['count']?.toString() ??
          json['number']?.toString() ??
          '',
      subtitle: json['subtitle']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'insights',
    );
  }
}

class AboutPillarsModel {
  final String sectionTitle;
  final String sectionSubtitle;
  final List<AboutPillarItem> items;

  AboutPillarsModel({
    this.sectionTitle = '',
    this.sectionSubtitle = '',
    this.items = const [],
  });

  factory AboutPillarsModel.fromJson(Map<String, dynamic> json) {
    return AboutPillarsModel(
      sectionTitle: json['section_title']?.toString() ?? '',
      sectionSubtitle: json['section_subtitle']?.toString() ?? '',
      items: (json['items'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => AboutPillarItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AboutPillarItem {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String theme;

  AboutPillarItem({
    this.id = '',
    this.title = '',
    this.description = '',
    this.icon = '',
    this.theme = 'emerald',
  });

  factory AboutPillarItem.fromJson(Map<String, dynamic> json) {
    return AboutPillarItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      theme: json['theme']?.toString() ?? 'emerald',
    );
  }
}

class AboutAppShowcaseModel {
  final String heading;
  final String subheading;
  final String imageUrl;
  final String downloadUrl;
  final List<AboutAppFeatureItem> features;

  AboutAppShowcaseModel({
    this.heading = '',
    this.subheading = '',
    this.imageUrl = '',
    this.downloadUrl = '',
    this.features = const [],
  });

  factory AboutAppShowcaseModel.fromJson(Map<String, dynamic> json) {
    return AboutAppShowcaseModel(
      heading: json['heading']?.toString() ?? '',
      subheading: json['subheading']?.toString() ?? '',
      imageUrl: Endpoints.resolveUrl(json['image_url']?.toString()),
      downloadUrl: json['download_url']?.toString() ?? '',
      features: (json['features'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => AboutAppFeatureItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AboutAppFeatureItem {
  final String title;
  final String description;
  final String icon;

  AboutAppFeatureItem({
    this.title = '',
    this.description = '',
    this.icon = '',
  });

  factory AboutAppFeatureItem.fromJson(Map<String, dynamic> json) {
    return AboutAppFeatureItem(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
    );
  }
}

class AboutCommunityAndSupportModel {
  final AboutHelplineModel? helpline;
  final AboutSocialChannelsModel? socialChannels;

  AboutCommunityAndSupportModel({this.helpline, this.socialChannels});

  factory AboutCommunityAndSupportModel.fromJson(Map<String, dynamic> json) {
    return AboutCommunityAndSupportModel(
      helpline: json['helpline'] is Map<String, dynamic>
          ? AboutHelplineModel.fromJson(json['helpline'] as Map<String, dynamic>)
          : null,
      socialChannels: json['social_channels'] is Map<String, dynamic>
          ? AboutSocialChannelsModel.fromJson(
              json['social_channels'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AboutHelplineModel {
  final String heading;
  final String subheading;
  final String activeHours;
  final String primaryPhone;
  final String? secondaryPhone;
  final List<String> phones;
  final String primaryEmail;
  final String? secondaryEmail;
  final List<String> emails;
  final String address;

  AboutHelplineModel({
    this.heading = '',
    this.subheading = '',
    this.activeHours = '',
    this.primaryPhone = '',
    this.secondaryPhone,
    this.phones = const [],
    this.primaryEmail = '',
    this.secondaryEmail,
    this.emails = const [],
    this.address = '',
  });

  factory AboutHelplineModel.fromJson(Map<String, dynamic> json) {
    final rawPhones = (json['phones'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final primaryP = json['primary_phone']?.toString() ?? (rawPhones.isNotEmpty ? rawPhones.first : '');
    final rawEmails = (json['emails'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final primaryE = json['primary_email']?.toString() ?? (rawEmails.isNotEmpty ? rawEmails.first : '');

    return AboutHelplineModel(
      heading: json['heading']?.toString() ?? '',
      subheading: json['subheading']?.toString() ?? '',
      activeHours: json['active_hours']?.toString() ?? '',
      primaryPhone: primaryP,
      secondaryPhone: json['secondary_phone']?.toString(),
      phones: rawPhones.isNotEmpty ? rawPhones : [primaryP],
      primaryEmail: primaryE,
      secondaryEmail: json['secondary_email']?.toString(),
      emails: rawEmails.isNotEmpty ? rawEmails : [primaryE],
      address: json['address']?.toString() ?? '',
    );
  }
}

class AboutSocialChannelsModel {
  final AboutSocialChannelItem? facebookPage;
  final AboutSocialChannelItem? facebookGroup;
  final AboutSocialChannelItem? youtube;
  final AboutSocialChannelItem? whatsapp;
  final AboutSocialChannelItem? telegram;

  AboutSocialChannelsModel({
    this.facebookPage,
    this.facebookGroup,
    this.youtube,
    this.whatsapp,
    this.telegram,
  });

  factory AboutSocialChannelsModel.fromJson(Map<String, dynamic> json) {
    return AboutSocialChannelsModel(
      facebookPage: json['facebook_page'] is Map<String, dynamic>
          ? AboutSocialChannelItem.fromJson(
              json['facebook_page'] as Map<String, dynamic>)
          : null,
      facebookGroup: json['facebook_group'] is Map<String, dynamic>
          ? AboutSocialChannelItem.fromJson(
              json['facebook_group'] as Map<String, dynamic>)
          : null,
      youtube: json['youtube'] is Map<String, dynamic>
          ? AboutSocialChannelItem.fromJson(
              json['youtube'] as Map<String, dynamic>)
          : null,
      whatsapp: json['whatsapp'] is Map<String, dynamic>
          ? AboutSocialChannelItem.fromJson(
              json['whatsapp'] as Map<String, dynamic>)
          : null,
      telegram: json['telegram'] is Map<String, dynamic>
          ? AboutSocialChannelItem.fromJson(
              json['telegram'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AboutSocialChannelItem {
  final String title;
  final String subtitle;
  final String url;
  final String? number;

  AboutSocialChannelItem({
    this.title = '',
    this.subtitle = '',
    this.url = '',
    this.number,
  });

  factory AboutSocialChannelItem.fromJson(Map<String, dynamic> json) {
    return AboutSocialChannelItem(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      number: json['number']?.toString(),
    );
  }
}

class AboutTestimonialsModel {
  final String heading;
  final String subheading;
  final List<AboutTestimonialItem> textTestimonials;
  final List<AboutTestimonialItem> videoTestimonials;
  final int totalCount;

  AboutTestimonialsModel({
    this.heading = '',
    this.subheading = '',
    this.textTestimonials = const [],
    this.videoTestimonials = const [],
    this.totalCount = 0,
  });

  factory AboutTestimonialsModel.fromJson(Map<String, dynamic> json) {
    final textList = (json['text_testimonials'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => AboutTestimonialItem.fromJson(e))
            .toList() ??
        [];
    final videoList = (json['video_testimonials'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => AboutTestimonialItem.fromJson(e))
            .toList() ??
        [];
    final counts = json['counts'] as Map<String, dynamic>?;
    final total = counts != null ? (counts['total'] as int? ?? (textList.length + videoList.length)) : (textList.length + videoList.length);

    return AboutTestimonialsModel(
      heading: json['heading']?.toString() ?? '',
      subheading: json['subheading']?.toString() ?? '',
      textTestimonials: textList,
      videoTestimonials: videoList,
      totalCount: total,
    );
  }
}

class AboutTestimonialItem {
  final int id;
  final String type; // 'text' or 'video'
  final String name;
  final String designation;
  final String? institution;
  final double rating;
  final String? reviewText;
  final String avatarUrl;
  final String? videoUrl;
  final String? videoEmbedUrl;
  final String? videoDuration;
  final String? youtubeId;

  AboutTestimonialItem({
    required this.id,
    this.type = 'text',
    this.name = '',
    this.designation = '',
    this.institution,
    this.rating = 5.0,
    this.reviewText,
    this.avatarUrl = '',
    this.videoUrl,
    this.videoEmbedUrl,
    this.videoDuration,
    this.youtubeId,
  });

  factory AboutTestimonialItem.fromJson(Map<String, dynamic> json) {
    return AboutTestimonialItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      type: json['type']?.toString() ?? 'text',
      name: json['name']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      institution: json['institution']?.toString(),
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 5.0,
      reviewText: json['review_text']?.toString(),
      avatarUrl: Endpoints.resolveUrl(json['avatar_url']?.toString()),
      videoUrl: json['video_url']?.toString(),
      videoEmbedUrl: json['video_embed_url']?.toString(),
      videoDuration: json['video_duration']?.toString(),
      youtubeId: json['youtube_id']?.toString(),
    );
  }
}

class AboutCtaModel {
  final String heading;
  final String subheading;
  final AboutButtonItem? buttonPrimary;
  final AboutButtonItem? buttonSecondary;

  AboutCtaModel({
    this.heading = '',
    this.subheading = '',
    this.buttonPrimary,
    this.buttonSecondary,
  });

  factory AboutCtaModel.fromJson(Map<String, dynamic> json) {
    return AboutCtaModel(
      heading: json['heading']?.toString() ?? '',
      subheading: json['subheading']?.toString() ?? '',
      buttonPrimary: json['button_primary'] is Map<String, dynamic>
          ? AboutButtonItem.fromJson(
              json['button_primary'] as Map<String, dynamic>)
          : null,
      buttonSecondary: json['button_secondary'] is Map<String, dynamic>
          ? AboutButtonItem.fromJson(
              json['button_secondary'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AboutButtonItem {
  final String text;
  final String url;

  AboutButtonItem({
    this.text = '',
    this.url = '',
  });

  factory AboutButtonItem.fromJson(Map<String, dynamic> json) {
    return AboutButtonItem(
      text: json['text']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }
}
