class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final String? status;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'status': status,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      status: json['status'],
    );
  }
}