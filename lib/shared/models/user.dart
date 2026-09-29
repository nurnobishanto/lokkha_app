class User {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? emailVerifiedAt;
  final String? dateOfBirth;
  final String? formattedDob;
  final String? gender;
  final String? occupation;
  final String? organization;
  final String? referralCode;
  final String? userId;
  final String? image;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final int? points;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? deletedAt;
  final String? jwtToken;
  final String? googleId;
  final String? facebookId;
  final String? githubId;
  final String? linkedinId;
  final String? twitterId;
  final String? avatar;
  final String? photoUrl;
  final String? provider;
  final String? referralLink;
  final int? rewardPoints;
  final bool? isSubscribed;
  final bool? hasActiveSubscription;
  final Map<String, dynamic>? activePackage;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.emailVerifiedAt,
    this.dateOfBirth,
    this.formattedDob,
    this.gender,
    this.occupation,
    this.organization,
    this.referralCode,
    this.userId,
    this.image,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.points,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.jwtToken,
    this.googleId,
    this.facebookId,
    this.githubId,
    this.linkedinId,
    this.twitterId,
    this.avatar,
    this.photoUrl,
    this.provider,
    this.referralLink,
    this.rewardPoints,
    this.isSubscribed,
    this.hasActiveSubscription,
    this.activePackage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final sub = json["has_active_subscription"] == true ||
        json["has_active_subscription"] == 1 ||
        json["is_subscribed"] == true ||
        json["is_subscribed"] == 1;

    return User(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      phone: json["phone"],
      emailVerifiedAt: json["email_verified_at"],
      dateOfBirth: json["date_of_birth"],
      formattedDob: json["formatted_dob"],
      gender: json["gender"],
      occupation: json["occupation"],
      organization: json["organization"],
      referralCode: json["referral_code"],
      userId: json["user_id"],
      image: json["image"] ?? json["photo_url"] ?? json["avatar"],
      addressLine1: json["address_line_1"],
      addressLine2: json["address_line_2"],
      city: json["city"],
      state: json["state"],
      zipCode: json["zip_code"],
      country: json["country"],
      points: json["points"] ?? json["reward_points"],
      createdAt: json["created_at"] == null
          ? null
          : DateTime.tryParse(json["created_at"].toString()),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.tryParse(json["updated_at"].toString()),
      deletedAt: json["deleted_at"],
      jwtToken: json["jwt_token"],
      googleId: json["google_id"],
      facebookId: json["facebook_id"],
      githubId: json["github_id"],
      linkedinId: json["linkedin_id"],
      avatar: json["avatar"],
      photoUrl: json["photo_url"] ?? json["image"] ?? json["avatar"],
      provider: json["provider"],
      referralLink: json["referral_link"],
      rewardPoints: json["reward_points"] ?? json["points"],
      isSubscribed: sub,
      hasActiveSubscription: sub,
      activePackage: json["active_package"] is Map<String, dynamic>
          ? json["active_package"] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "email_verified_at": emailVerifiedAt,
        "date_of_birth": dateOfBirth,
        "formatted_dob": formattedDob,
        "gender": gender,
        "occupation": occupation,
        "organization": organization,
        "referral_code": referralCode,
        "user_id": userId,
        "image": image,
        "address_line_1": addressLine1,
        "address_line_2": addressLine2,
        "city": city,
        "state": state,
        "zip_code": zipCode,
        "country": country,
        "points": points,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
        "jwt_token": jwtToken,
        "google_id": googleId,
        "facebook_id": facebookId,
        "github_id": githubId,
        "linkedin_id": linkedinId,
        "twitter_id": twitterId,
        "avatar": avatar,
        "photo_url": photoUrl ?? image ?? avatar,
        "provider": provider,
        "referral_link": referralLink,
        "reward_points": rewardPoints ?? points,
        "is_subscribed": isSubscribed,
        "has_active_subscription": hasActiveSubscription,
        "active_package": activePackage,
      };
}
