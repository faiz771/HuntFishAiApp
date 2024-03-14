class SetYourProfileRequest {
  int? role;
  String? profileUrl;
  String? experience;
  String? location;
  String? latitude;
  String? longitude;
  String? equipment;
  String? preferences;
  String? season;
  String? full_name;
  String? intrests;
  String? regulatoryUnderstanding;
  String? physicalCapabilities;

  SetYourProfileRequest(
      {this.role,
      this.profileUrl,
      this.experience,
      this.location,
      this.latitude,
      this.longitude,
      this.full_name,
      this.equipment,
      this.preferences,
      this.season,
      this.intrests,
      this.regulatoryUnderstanding,
      this.physicalCapabilities});

  SetYourProfileRequest.fromJson(Map<String, dynamic> json) {
    role = 1;
    profileUrl = json['profile_url'];
    experience = json['experience'];
    location = json['location'];
    full_name = json['full_name'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    equipment = json['equipment'];
    preferences = json['preferences'];
    season = json['season'];
    intrests = json['intrests'];
    regulatoryUnderstanding = json['regulatory_understanding'];
    physicalCapabilities = json['physical_capabilities'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['role'] = role;
    data['profile_url'] = profileUrl;
    data['experience'] = experience;
    data['location'] = location;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['equipment'] = equipment;
    data['full_name'] = full_name;
    data['preferences'] = preferences;
    data['season'] = season;
    data['intrests'] = intrests;
    data['regulatory_understanding'] = regulatoryUnderstanding;
    data['physical_capabilities'] = physicalCapabilities;
    return data;
  }
}
