class DeviceSessionModel {
  final int id;
  final String deviceName;
  final String deviceType;
  final String platform;
  final String? platformCategory;
  final String? platformCategoryLabel;
  final String? ipAddress;
  final bool isActive;
  final bool isCurrent;
  final String? loginAt;
  final String? lastActiveAt;

  DeviceSessionModel({
    required this.id,
    required this.deviceName,
    this.deviceType = 'mobile',
    required this.platform,
    this.platformCategory,
    this.platformCategoryLabel,
    this.ipAddress,
    this.isActive = true,
    this.isCurrent = false,
    this.loginAt,
    this.lastActiveAt,
  });

  factory DeviceSessionModel.fromJson(Map<String, dynamic> json) {
    return DeviceSessionModel(
      id: json['id'] as int? ?? 0,
      deviceName: json['device_name'] as String? ?? 'Unknown Device',
      deviceType: json['device_type'] as String? ?? 'mobile',
      platform: json['platform'] as String? ?? 'android',
      platformCategory: json['platform_category'] as String?,
      platformCategoryLabel: json['platform_category_label'] as String?,
      ipAddress: json['ip_address'] as String?,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      isCurrent: json['is_current'] == true || json['is_current'] == 1,
      loginAt: json['login_at'] as String?,
      lastActiveAt: json['last_active_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'device_name': deviceName,
        'device_type': deviceType,
        'platform': platform,
        'platform_category': platformCategory,
        'platform_category_label': platformCategoryLabel,
        'ip_address': ipAddress,
        'is_active': isActive,
        'is_current': isCurrent,
        'login_at': loginAt,
        'last_active_at': lastActiveAt,
      };
}

class UserDevicesData {
  final List<DeviceSessionModel> activeDevices;
  final int activeCount;
  final int maxAllowed;
  final List<dynamic>? historyItems;

  UserDevicesData({
    required this.activeDevices,
    this.activeCount = 0,
    this.maxAllowed = 3,
    this.historyItems,
  });

  factory UserDevicesData.fromJson(Map<String, dynamic> json) {
    List<DeviceSessionModel> devices = [];
    if (json['active_devices'] is List) {
      devices = (json['active_devices'] as List)
          .map((e) => DeviceSessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return UserDevicesData(
      activeDevices: devices,
      activeCount: json['active_count'] as int? ?? devices.length,
      maxAllowed: json['max_allowed'] as int? ?? 3,
      historyItems: json['history'] is Map && json['history']['items'] is List
          ? json['history']['items'] as List
          : null,
    );
  }
}
