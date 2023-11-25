
import 'dart:convert';

class ComplaintRequestModel {
  var fullName;
  var email;
  var phoneNo;
  var complaintCategory;
  var subject;
  var description;

  ComplaintRequestModel({
    this.fullName,
    this.email,
    this.phoneNo,
    this.complaintCategory,
    this.subject,
    this.description,
  });

  String toJson() {
    return jsonEncode(<String, dynamic>{
      "fullName": fullName,
      "email": email,
      "phoneNo": phoneNo,
      "complaintCategory": complaintCategory,
      "subject": subject,
      "description": description,
    });
  }
}