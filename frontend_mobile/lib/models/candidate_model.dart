class CandidateModel {
  final String id;
  final String candidateId;
  final String name;
  final String party;
  final String? logo;
  final String? image;

  CandidateModel({
    required this.id,
    required this.candidateId,
    required this.name,
    required this.party,
    this.logo,
    this.image,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json, String documentId) {
    return CandidateModel(
      id: documentId,
      candidateId: json['candidateId'] ?? '',
      name: json['name'] ?? '',
      party: json['party'] ?? '',
      logo: json['logo'],
      image: json['image'],
    );
  }
}
