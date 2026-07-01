

class InventoryTransaction {
  final int? id;
  final int partId;
  final String type; 
  final int quantity;
  final DateTime? date;
  final String? note;

  InventoryTransaction({
    this.id,
    required this.partId,
    required this.type,
    required this.quantity,
    this.date,
    this.note,
  });


  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'part_id': partId,
      'type': type,
      'quantity': quantity,
      if (note != null) 'note': note,

    };
  }


  factory InventoryTransaction.fromMap(Map<String, dynamic> map) {
    return InventoryTransaction(
      id: map['id'],
      partId: map['part_id'],
      type: map['type'],
      quantity: map['quantity'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      note: map['note'],
    );
  }
}