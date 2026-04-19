class UserModel {
  final String id;
  final String voterId;
  final String epicNumber;
  final String name;
  final String fatherName;
  final String gender;
  final String dob;
  final int age;
  final String phone;
  final String address;
  final String constituency;
  final String pollingStation;
  final String district;
  final String state;
  final String pincode;
  final bool hasVoted;

  UserModel({
    required this.id,
    required this.voterId,
    required this.epicNumber,
    required this.name,
    required this.fatherName,
    required this.gender,
    required this.dob,
    required this.age,
    required this.phone,
    required this.address,
    required this.constituency,
    required this.pollingStation,
    required this.district,
    required this.state,
    required this.pincode,
    required this.hasVoted,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      voterId: json['voterId'] ?? '',
      epicNumber: json['epicNumber'] ?? '',
      name: json['name'] ?? '',
      fatherName: json['fatherName'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      age: json['age'] ?? 0,
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      constituency: json['constituency'] ?? '',
      pollingStation: json['pollingStation'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      hasVoted: json['hasVoted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'voterId': voterId,
      'epicNumber': epicNumber,
      'name': name,
      'fatherName': fatherName,
      'gender': gender,
      'dob': dob,
      'age': age,
      'phone': phone,
      'address': address,
      'constituency': constituency,
      'pollingStation': pollingStation,
      'district': district,
      'state': state,
      'pincode': pincode,
      'hasVoted': hasVoted,
    };
  }
}
