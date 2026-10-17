class UserModel {
  final int idUser;
  final String nama;
  final String email;

  UserModel({
    required this.idUser,
    required this.nama,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: json['id_user'] is int
          ? json['id_user']
          : int.tryParse(json['id_user'].toString()) ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'nama': nama,
      'email': email,
    };
  }
}
