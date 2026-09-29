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
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        subject: json["subject"],
        qualification: json["qualification"],
        experience: json["experience"],
        status: json["status"],
        address: json["address"],
        profilePicture: json["profile_picture"],
        video: json["video"],
        image: json["image"],
        advancedInfo: json["advanced_info"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
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
