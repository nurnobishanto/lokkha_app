class DeviceSessionModel {
  final int id;
  final String deviceName;
  final String platform;
  final String? ipAddress;
  final String? lastActiveAt;
  final bool isCurrent;

  DeviceSessionModel({
    required this.id,
    required this.deviceName,
    required this.platform,
    this.ipAddress,
    this.lastActiveAt,
    this.isCurrent = false,
  });

  factory DeviceSessionModel.fromJson(Map<String, dynamic> json) {
    return DeviceSessionModel(
      id: json['id'] as int? ?? 0,
      deviceName: json['device_name'] as String? ?? 'Unknown Device',
      platform: json['platform'] as String? ?? 'android',
      ipAddress: json['ip_address'] as String?,
      lastActiveAt: json['last_active_at'] as String?,
      isCurrent: json['is_current'] == true || json['is_current'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'device_name': deviceName,
        'platform': platform,
        'ip_address': ipAddress,
        'last_active_at': lastActiveAt,
        'is_current': isCurrent,
      };
}
