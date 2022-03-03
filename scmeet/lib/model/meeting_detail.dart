class MeetingDetail {
  String id;
  String hostId;
  String hostName;

  MeetingDetail({required this.id, required this.hostId, required this.hostName});

  factory MeetingDetail.fromJson(dynamic json) {
    return MeetingDetail(
      id: json['id'],
      hostId: json['hostId'],
      hostName: "hostName",
    );
  }
}
