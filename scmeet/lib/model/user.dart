class User {
  String? email;
  String? name;
  String? surname;
  String? id;
  String? isHost; // 0 false 1 true
  String? company;

  setUserData(String email, String name, String surname, String id, String isHost, String company) {
    this.email = email;
    this.name = name;
    this.surname = surname;
    this.id = id;
    this.isHost = isHost;
    this.company = company;

  }


}