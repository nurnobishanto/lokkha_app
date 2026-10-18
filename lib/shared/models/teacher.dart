class Teacher {
  final int? id;
  final String? name;
  final String? email;
  final dynamic phone;
  final String? subject;
  final dynamic qualification;
  final int? experience;
  final String? status;
  final dynamic address;
  final String? profilePicture;
  final dynamic video;
  final String? image;
  final dynamic advancedInfo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;

  Teacher({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.subject,
    this.qualification,
    this.experience,
    this.status,
    this.address,
    this.profilePicture,
    this.video,
    this.image,
    this.advancedInfo,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
        id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? ''),
        name: json["name"]?.toString(),
        email: json["email"]?.toString(),
        phone: json["phone"],
        subject: json["subject"]?.toString() ?? json["designation"]?.toString(),
        qualification: json["qualification"] ?? json["institution"],
        experience: json["experience"] is int ? json["experience"] : int.tryParse(json["experience"]?.toString() ?? ''),
        status: json["status"]?.toString(),
        address: json["address"],
        profilePicture: json["profile_picture"]?.toString() ?? json["image_url"]?.toString(),
        video: json["video"],
        image: json["image"]?.toString() ?? json["image_url"]?.toString(),
        advancedInfo: json["advanced_info"] ?? json["bio"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"].toString()),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.tryParse(json["updated_at"].toString()),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "subject": subject,
        "qualification": qualification,
        "experience": experience,
        "status": status,
        "address": address,
        "profile_picture": profilePicture,
        "video": video,
        "image": image,
        "advanced_info": advancedInfo,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
      };
}
