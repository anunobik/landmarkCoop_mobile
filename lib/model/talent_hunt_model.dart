class ContestantResponseModel {
  final int id;
  final String stageName;
  final String firstName;
  final String middleName;
  final String lastName;
  final String dateOfBirth;
  final String gender;
  final String talentType;
  final String singleOrGroup;
  final String biography;
  final String educationLevel;
  final String countryState;
  final String hobby;
  final int numberOfVotes;

  ContestantResponseModel(
      {required this.id,
        required this.stageName,
        required this.firstName,
        required this.middleName,
        required this.lastName,
        required this.dateOfBirth,
        required this.gender,
        required this.talentType,
        required this.singleOrGroup,
        required this.biography,
        required this.educationLevel,
        required this.countryState,
        required this.hobby,
        required this.numberOfVotes,
      });

  factory ContestantResponseModel.fromJson(Map<String, dynamic> json) {
    return ContestantResponseModel(
      id: json['id'] ?? 0,
      stageName: json['stageName'] ?? '',
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'] ?? '',
      lastName: json['lastName'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      gender: json['gender'] ?? '',
      talentType: json['talentType'] ?? '',
      singleOrGroup: json['singleOrGroup'] ?? '',
      biography: json['biography'] ?? '',
      educationLevel: json['educationLevel'] ?? '',
      countryState: json['countryState'] ?? '',
      hobby: json['hobby'] ?? '',
      numberOfVotes: json['numberOfVotes'] ?? 0,
    );
  }
}