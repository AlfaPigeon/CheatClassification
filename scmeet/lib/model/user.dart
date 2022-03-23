class User {
  String? email;
  String? name;
  String? surname;
  String? id;

  setUserData(String email, String name, String surname, String id) {
    this.email = email;
    this.name = name;
    this.surname = surname;
    this.id = id;

    print(this.email);
    print(this.name);
    print(this.surname);
    print(this.id);

  }


}