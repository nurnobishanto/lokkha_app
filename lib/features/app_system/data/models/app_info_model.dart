class AppInfoModel {
  final bool success;
  final String message;
  final AppInfoDataModel data;

  AppInfoModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AppInfoModel.fromJson(Map<String, dynamic> json) {
    return AppInfoModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? AppInfoDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : AppInfoDataModel.empty(),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.toJson(),
      };
}

class AppInfoDataModel {
  final AppIdentityModel app;
  final AppVersionsModel versions;
  final SystemStatusModel systemStatus;
  final AppContactModel contact;
  final SocialLinksModel socialLinks;
  final DownloadLinksModel downloads;
  final LegalLinksModel legalLinks;
  final AnnouncementsModel announcements;
  final ClientVersionCheckModel? clientVersionCheck;

  AppInfoDataModel({
    required this.app,
    required this.versions,
    required this.systemStatus,
    required this.contact,
    required this.socialLinks,
    required this.downloads,
    required this.legalLinks,
    required this.announcements,
    this.clientVersionCheck,
  });

  factory AppInfoDataModel.empty() {
    return AppInfoDataModel(
      app: AppIdentityModel.empty(),
      versions: AppVersionsModel.empty(),
      systemStatus: SystemStatusModel.empty(),
      contact: AppContactModel.empty(),
      socialLinks: SocialLinksModel.empty(),
      downloads: DownloadLinksModel.empty(),
      legalLinks: LegalLinksModel.empty(),
      announcements: AnnouncementsModel.empty(),
      clientVersionCheck: null,
    );
  }

  factory AppInfoDataModel.fromJson(Map<String, dynamic> json) {
    return AppInfoDataModel(
      app: json['app'] is Map<String, dynamic>
          ? AppIdentityModel.fromJson(json['app'] as Map<String, dynamic>)
          : AppIdentityModel.empty(),
      versions: json['versions'] is Map<String, dynamic>
          ? AppVersionsModel.fromJson(json['versions'] as Map<String, dynamic>)
          : AppVersionsModel.empty(),
      systemStatus: json['system_status'] is Map<String, dynamic>
          ? SystemStatusModel.fromJson(
              json['system_status'] as Map<String, dynamic>)
          : SystemStatusModel.empty(),
      contact: json['contact'] is Map<String, dynamic>
          ? AppContactModel.fromJson(json['contact'] as Map<String, dynamic>)
          : AppContactModel.empty(),
      socialLinks: json['social_links'] is Map<String, dynamic>
          ? SocialLinksModel.fromJson(
              json['social_links'] as Map<String, dynamic>)
          : SocialLinksModel.empty(),
      downloads: json['downloads'] is Map<String, dynamic>
          ? DownloadLinksModel.fromJson(
              json['downloads'] as Map<String, dynamic>)
          : DownloadLinksModel.empty(),
      legalLinks: json['legal_links'] is Map<String, dynamic>
          ? LegalLinksModel.fromJson(
              json['legal_links'] as Map<String, dynamic>)
          : LegalLinksModel.empty(),
      announcements: json['announcements'] is Map<String, dynamic>
          ? AnnouncementsModel.fromJson(
              json['announcements'] as Map<String, dynamic>)
          : AnnouncementsModel.empty(),
      clientVersionCheck: json['client_version_check'] is Map<String, dynamic>
          ? ClientVersionCheckModel.fromJson(
              json['client_version_check'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'app': app.toJson(),
        'versions': versions.toJson(),
        'system_status': systemStatus.toJson(),
        'contact': contact.toJson(),
        'social_links': socialLinks.toJson(),
        'downloads': downloads.toJson(),
        'legal_links': legalLinks.toJson(),
        'announcements': announcements.toJson(),
        if (clientVersionCheck != null)
          'client_version_check': clientVersionCheck!.toJson(),
      };
}

class AppIdentityModel {
  final String name;
  final String tagline;
  final String description;
  final String logoUrl;
  final String logoLightUrl;
  final String faviconUrl;
  final String websiteUrl;
  final String copyright;

  AppIdentityModel({
    required this.name,
    required this.tagline,
    required this.description,
    required this.logoUrl,
    required this.logoLightUrl,
    required this.faviconUrl,
    required this.websiteUrl,
    required this.copyright,
  });

  factory AppIdentityModel.empty() => AppIdentityModel(
        name: 'Lokkha - লক্ষ্য',
        tagline: 'সঠিক পথে, স্বল্প সময়ে',
        description: '',
        logoUrl: '',
        logoLightUrl: '',
        faviconUrl: '',
        websiteUrl: 'https://lokkha.com',
        copyright: '',
      );

  factory AppIdentityModel.fromJson(Map<String, dynamic> json) =>
      AppIdentityModel(
        name: json['name']?.toString() ?? 'Lokkha - লক্ষ্য',
        tagline: json['tagline']?.toString() ?? 'সঠিক পথে, স্বল্প সময়ে',
        description: json['description']?.toString() ?? '',
        logoUrl: json['logo_url']?.toString() ?? '',
        logoLightUrl: json['logo_light_url']?.toString() ?? '',
        faviconUrl: json['favicon_url']?.toString() ?? '',
        websiteUrl: json['website_url']?.toString() ?? 'https://lokkha.com',
        copyright: json['copyright']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'tagline': tagline,
        'description': description,
        'logo_url': logoUrl,
        'logo_light_url': logoLightUrl,
        'favicon_url': faviconUrl,
        'website_url': websiteUrl,
        'copyright': copyright,
      };
}

class AppVersionsModel {
  final PlatformBuildModel android;
  final PlatformBuildModel ios;

  AppVersionsModel({
    required this.android,
    required this.ios,
  });

  factory AppVersionsModel.empty() => AppVersionsModel(
        android: PlatformBuildModel.empty('android'),
        ios: PlatformBuildModel.empty('ios'),
      );

  factory AppVersionsModel.fromJson(Map<String, dynamic> json) =>
      AppVersionsModel(
        android: json['android'] is Map<String, dynamic>
            ? PlatformBuildModel.fromJson(
                json['android'] as Map<String, dynamic>, 'android')
            : PlatformBuildModel.empty('android'),
        ios: json['ios'] is Map<String, dynamic>
            ? PlatformBuildModel.fromJson(
                json['ios'] as Map<String, dynamic>, 'ios')
            : PlatformBuildModel.empty('ios'),
      );

  Map<String, dynamic> toJson() => {
        'android': android.toJson(),
        'ios': ios.toJson(),
      };
}

class PlatformBuildModel {
  final String platform;
  final String latestVersionName;
  final String latestVersionCode;
  final bool forceUpdate;
  final bool maintenanceMode;
  final String downloadUrl;
  final String? packageName;
  final String? bundleId;

  PlatformBuildModel({
    required this.platform,
    required this.latestVersionName,
    required this.latestVersionCode,
    required this.forceUpdate,
    required this.maintenanceMode,
    required this.downloadUrl,
    this.packageName,
    this.bundleId,
  });

  factory PlatformBuildModel.empty(String platform) => PlatformBuildModel(
        platform: platform,
        latestVersionName: '1.0.0',
        latestVersionCode: '1',
        forceUpdate: false,
        maintenanceMode: false,
        downloadUrl: '',
      );

  factory PlatformBuildModel.fromJson(
      Map<String, dynamic> json, String platform) {
    return PlatformBuildModel(
      platform: platform,
      latestVersionName: json['latest_version_name']?.toString() ?? '1.0.0',
      latestVersionCode: json['latest_version_code']?.toString() ?? '1',
      forceUpdate: json['force_update'] == true ||
          json['force_update'] == 1 ||
          json['force_update'] == '1',
      maintenanceMode: json['maintenance_mode'] == true ||
          json['maintenance_mode'] == 1 ||
          json['maintenance_mode'] == '1',
      downloadUrl: json['download_url']?.toString() ?? '',
      packageName: json['package_name']?.toString(),
      bundleId: json['bundle_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'latest_version_name': latestVersionName,
        'latest_version_code': latestVersionCode,
        'force_update': forceUpdate,
        'maintenance_mode': maintenanceMode,
        'download_url': downloadUrl,
        if (packageName != null) 'package_name': packageName,
        if (bundleId != null) 'bundle_id': bundleId,
      };
}

class SystemStatusModel {
  final bool isUnderMaintenance;
  final String maintenanceTitle;
  final String maintenanceMessage;

  SystemStatusModel({
    required this.isUnderMaintenance,
    required this.maintenanceTitle,
    required this.maintenanceMessage,
  });

  factory SystemStatusModel.empty() => SystemStatusModel(
        isUnderMaintenance: false,
        maintenanceTitle: 'অ্যাপ রক্ষণাবেক্ষণ চলছে',
        maintenanceMessage:
            'আমাদের সিস্টেম আপগ্রেডেশনের কাজ চলছে। খুব শীঘ্রই অ্যাপটি স্বাভাবিকভাবে চালু হবে। সাথে থাকার জন্য ধন্যবাদ।',
      );

  factory SystemStatusModel.fromJson(Map<String, dynamic> json) =>
      SystemStatusModel(
        isUnderMaintenance: json['is_under_maintenance'] == true ||
            json['is_under_maintenance'] == 1 ||
            json['is_under_maintenance'] == '1',
        maintenanceTitle: json['maintenance_title']?.toString() ??
            'অ্যাপ রক্ষণাবেক্ষণ চলছে',
        maintenanceMessage: json['maintenance_message']?.toString() ??
            'আমাদের সিস্টেম আপগ্রেডেশনের কাজ চলছে। খুব শীঘ্রই অ্যাপটি স্বাভাবিকভাবে চালু হবে। সাথে থাকার জন্য ধন্যবাদ।',
      );

  Map<String, dynamic> toJson() => {
        'is_under_maintenance': isUnderMaintenance,
        'maintenance_title': maintenanceTitle,
        'maintenance_message': maintenanceMessage,
      };
}

class AppContactModel {
  final String officeLabel;
  final String address;
  final String officeHours;
  final String primaryPhone;
  final String? secondaryPhone;
  final List<String> phones;
  final String primaryEmail;
  final String supportEmail;
  final List<String> emails;

  AppContactModel({
    required this.officeLabel,
    required this.address,
    required this.officeHours,
    required this.primaryPhone,
    this.secondaryPhone,
    required this.phones,
    required this.primaryEmail,
    required this.supportEmail,
    required this.emails,
  });

  factory AppContactModel.empty() => AppContactModel(
        officeLabel: 'আমাদের অফিস',
        address:
            'রূপায়ন-লতিফা শামসুদ্দিন স্কয়ার, মিরপুর ১, ঢাকা - ১২১৬',
        officeHours: 'সকাল ৯টা - রাত ৯টা',
        primaryPhone: '(+880) 1334-260543',
        secondaryPhone: null,
        phones: ['(+880) 1334-260543'],
        primaryEmail: 'info@lokkha.com',
        supportEmail: 'support@lokkha.com',
        emails: ['info@lokkha.com', 'support@lokkha.com'],
      );

  factory AppContactModel.fromJson(Map<String, dynamic> json) {
    final rawPhones = json['phones'];
    final phoneList = rawPhones is List
        ? rawPhones.map((e) => e.toString()).toList()
        : <String>[];

    final rawEmails = json['emails'];
    final emailList = rawEmails is List
        ? rawEmails.map((e) => e.toString()).toList()
        : <String>[];

    return AppContactModel(
      officeLabel: json['office_label']?.toString() ?? 'আমাদের অফিস',
      address: json['address']?.toString() ?? '',
      officeHours: json['office_hours']?.toString() ?? '',
      primaryPhone: json['primary_phone']?.toString() ?? '',
      secondaryPhone: json['secondary_phone']?.toString(),
      phones: phoneList,
      primaryEmail: json['primary_email']?.toString() ?? '',
      supportEmail: json['support_email']?.toString() ?? '',
      emails: emailList,
    );
  }

  Map<String, dynamic> toJson() => {
        'office_label': officeLabel,
        'address': address,
        'office_hours': officeHours,
        'primary_phone': primaryPhone,
        'secondary_phone': secondaryPhone,
        'phones': phones,
        'primary_email': primaryEmail,
        'support_email': supportEmail,
        'emails': emails,
      };
}

class SocialLinksModel {
  final String? facebookPage;
  final String? facebookGroup;
  final String? youtube;
  final String? whatsappNumber;
  final String? whatsappUrl;
  final String? telegram;

  SocialLinksModel({
    this.facebookPage,
    this.facebookGroup,
    this.youtube,
    this.whatsappNumber,
    this.whatsappUrl,
    this.telegram,
  });

  factory SocialLinksModel.empty() => SocialLinksModel(
        facebookPage: 'https://www.facebook.com/lokkhabd',
        facebookGroup: 'https://www.facebook.com/groups/lokkha',
        youtube: 'https://www.youtube.com/@lokkhabd',
        whatsappNumber: '+8801334260543',
        whatsappUrl: 'https://wa.me/+8801334260543',
      );

  factory SocialLinksModel.fromJson(Map<String, dynamic> json) =>
      SocialLinksModel(
        facebookPage: json['facebook_page']?.toString(),
        facebookGroup: json['facebook_group']?.toString(),
        youtube: json['youtube']?.toString(),
        whatsappNumber: json['whatsapp_number']?.toString(),
        whatsappUrl: json['whatsapp_url']?.toString(),
        telegram: json['telegram']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'facebook_page': facebookPage,
        'facebook_group': facebookGroup,
        'youtube': youtube,
        'whatsapp_number': whatsappNumber,
        'whatsapp_url': whatsappUrl,
        'telegram': telegram,
      };
}

class DownloadLinksModel {
  final String googlePlayUrl;
  final String appStoreUrl;

  DownloadLinksModel({
    required this.googlePlayUrl,
    required this.appStoreUrl,
  });

  factory DownloadLinksModel.empty() => DownloadLinksModel(
        googlePlayUrl:
            'https://play.google.com/store/apps/details?id=com.techyfo.lokkha',
        appStoreUrl:
            'https://play.google.com/store/apps/details?id=com.techyfo.lokkha&hl=en',
      );

  factory DownloadLinksModel.fromJson(Map<String, dynamic> json) =>
      DownloadLinksModel(
        googlePlayUrl: json['google_play_url']?.toString() ?? '',
        appStoreUrl: json['app_store_url']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'google_play_url': googlePlayUrl,
        'app_store_url': appStoreUrl,
      };
}

class LegalLinksModel {
  final String privacyPolicy;
  final String termsAndConditions;
  final String refundPolicy;
  final String contestPolicy;
  final String aboutUs;
  final String contactUs;

  LegalLinksModel({
    required this.privacyPolicy,
    required this.termsAndConditions,
    required this.refundPolicy,
    required this.contestPolicy,
    required this.aboutUs,
    required this.contactUs,
  });

  factory LegalLinksModel.empty() => LegalLinksModel(
        privacyPolicy: 'https://lokkha.com/privacy-policy',
        termsAndConditions: 'https://lokkha.com/terms-and-conditions',
        refundPolicy: 'https://lokkha.com/refund-policy',
        contestPolicy: 'https://lokkha.com/contest-policy',
        aboutUs: 'https://lokkha.com/about',
        contactUs: 'https://lokkha.com/contact',
      );

  factory LegalLinksModel.fromJson(Map<String, dynamic> json) =>
      LegalLinksModel(
        privacyPolicy: json['privacy_policy']?.toString() ?? '',
        termsAndConditions: json['terms_and_conditions']?.toString() ?? '',
        refundPolicy: json['refund_policy']?.toString() ?? '',
        contestPolicy: json['contest_policy']?.toString() ?? '',
        aboutUs: json['about_us']?.toString() ?? '',
        contactUs: json['contact_us']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'privacy_policy': privacyPolicy,
        'terms_and_conditions': termsAndConditions,
        'refund_policy': refundPolicy,
        'contest_policy': contestPolicy,
        'about_us': aboutUs,
        'contact_us': contactUs,
      };
}

class AnnouncementsModel {
  final TopBarAnnouncementModel topBar;
  final PromoBarAnnouncementModel promoBar;
  final InAppPopupModel inAppPopup;

  AnnouncementsModel({
    required this.topBar,
    required this.promoBar,
    required this.inAppPopup,
  });

  factory AnnouncementsModel.empty() => AnnouncementsModel(
        topBar: TopBarAnnouncementModel.empty(),
        promoBar: PromoBarAnnouncementModel.empty(),
        inAppPopup: InAppPopupModel.empty(),
      );

  factory AnnouncementsModel.fromJson(Map<String, dynamic> json) =>
      AnnouncementsModel(
        topBar: json['top_bar'] is Map<String, dynamic>
            ? TopBarAnnouncementModel.fromJson(
                json['top_bar'] as Map<String, dynamic>)
            : TopBarAnnouncementModel.empty(),
        promoBar: json['promo_bar'] is Map<String, dynamic>
            ? PromoBarAnnouncementModel.fromJson(
                json['promo_bar'] as Map<String, dynamic>)
            : PromoBarAnnouncementModel.empty(),
        inAppPopup: json['in_app_popup'] is Map<String, dynamic>
            ? InAppPopupModel.fromJson(
                json['in_app_popup'] as Map<String, dynamic>)
            : InAppPopupModel.empty(),
      );

  Map<String, dynamic> toJson() => {
        'top_bar': topBar.toJson(),
        'promo_bar': promoBar.toJson(),
        'in_app_popup': inAppPopup.toJson(),
      };
}

class TopBarAnnouncementModel {
  final bool enabled;
  final String title;
  final String subtitle;

  TopBarAnnouncementModel({
    required this.enabled,
    required this.title,
    required this.subtitle,
  });

  factory TopBarAnnouncementModel.empty() => TopBarAnnouncementModel(
        enabled: false,
        title: '',
        subtitle: '',
      );

  factory TopBarAnnouncementModel.fromJson(Map<String, dynamic> json) =>
      TopBarAnnouncementModel(
        enabled: json['enabled'] == true,
        title: json['title']?.toString() ?? '',
        subtitle: json['subtitle']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'title': title,
        'subtitle': subtitle,
      };
}

class PromoBarAnnouncementModel {
  final bool enabled;
  final String text;
  final String highlight;
  final String buttonText;
  final String url;
  final String targetDate;

  PromoBarAnnouncementModel({
    required this.enabled,
    required this.text,
    required this.highlight,
    required this.buttonText,
    required this.url,
    required this.targetDate,
  });

  factory PromoBarAnnouncementModel.empty() => PromoBarAnnouncementModel(
        enabled: false,
        text: '',
        highlight: '',
        buttonText: '',
        url: '',
        targetDate: '',
      );

  factory PromoBarAnnouncementModel.fromJson(Map<String, dynamic> json) =>
      PromoBarAnnouncementModel(
        enabled: json['enabled'] == true,
        text: json['text']?.toString() ?? '',
        highlight: json['highlight']?.toString() ?? '',
        buttonText: json['button_text']?.toString() ?? '',
        url: json['url']?.toString() ?? '',
        targetDate: json['target_date']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'text': text,
        'highlight': highlight,
        'button_text': buttonText,
        'url': url,
        'target_date': targetDate,
      };
}

class InAppPopupModel {
  final bool enabled;
  final String heading;
  final String? details;
  final String imageUrl;
  final String buttonText;
  final String targetUrl;

  InAppPopupModel({
    required this.enabled,
    required this.heading,
    this.details,
    required this.imageUrl,
    required this.buttonText,
    required this.targetUrl,
  });

  factory InAppPopupModel.empty() => InAppPopupModel(
        enabled: false,
        heading: '',
        details: null,
        imageUrl: '',
        buttonText: '',
        targetUrl: '',
      );

  factory InAppPopupModel.fromJson(Map<String, dynamic> json) => InAppPopupModel(
        enabled: json['enabled'] == true,
        heading: json['heading']?.toString() ?? '',
        details: json['details']?.toString(),
        imageUrl: json['image_url']?.toString() ?? '',
        buttonText: json['button_text']?.toString() ?? '',
        targetUrl: json['target_url']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'heading': heading,
        'details': details,
        'image_url': imageUrl,
        'button_text': buttonText,
        'target_url': targetUrl,
      };
}

class ClientVersionCheckModel {
  final String platform;
  final String currentVersion;
  final bool hasUpdate;
  final bool updateRequired;
  final String latestVersionName;
  final String latestVersionCode;
  final String? downloadUrl;
  final bool maintenanceMode;
  final String message;

  ClientVersionCheckModel({
    required this.platform,
    required this.currentVersion,
    required this.hasUpdate,
    required this.updateRequired,
    required this.latestVersionName,
    required this.latestVersionCode,
    this.downloadUrl,
    required this.maintenanceMode,
    required this.message,
  });

  factory ClientVersionCheckModel.fromJson(Map<String, dynamic> json) {
    return ClientVersionCheckModel(
      platform: json['platform']?.toString() ?? 'android',
      currentVersion: json['current_version']?.toString() ?? '',
      hasUpdate: json['has_update'] == true,
      updateRequired: json['update_required'] == true,
      latestVersionName: json['latest_version_name']?.toString() ?? '',
      latestVersionCode: json['latest_version_code']?.toString() ?? '',
      downloadUrl: json['download_url']?.toString(),
      maintenanceMode: json['maintenance_mode'] == true,
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'current_version': currentVersion,
        'has_update': hasUpdate,
        'update_required': updateRequired,
        'latest_version_name': latestVersionName,
        'latest_version_code': latestVersionCode,
        'download_url': downloadUrl,
        'maintenance_mode': maintenanceMode,
        'message': message,
      };
}
