import 'dart:convert';

class MockSubjectSelect {
  final int? id;
  final String? name;
  final int? quantity;
  final int? max;
  final int? parentId; // ✅ New Field Added

  // Constructor
  MockSubjectSelect({
    this.id,
    this.name,
    this.quantity,
    this.max,
    this.parentId, // ✅ Include in constructor
  });

  // Convert a MockSubjectSelect object to a Map (for JSON encoding)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'max': max,
      'parentId': parentId, // ✅ Include in map
    };
  }

  // Convert a Map into a MockSubjectSelect object
  factory MockSubjectSelect.fromMap(Map<String, dynamic> map) {
    return MockSubjectSelect(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      max: map['max'],
      parentId: map['parentId'], // ✅ Include from map
    );
  }

  // Convert MockSubjectSelect to a JSON string
  String toJson() => json.encode(toMap());

  // Convert JSON string back to a MockSubjectSelect object
  factory MockSubjectSelect.fromJson(String source) =>
      MockSubjectSelect.fromMap(json.decode(source));

  // Print object values
  @override
  String toString() {
    return 'ID: $id, Name: $name, Quantity: $quantity, Max: $max, ParentID: $parentId';
  }
}
