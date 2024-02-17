class InvoiceAnalysis {
  List<Item> whichItemsBought;
  String anyHealthProblem;
  String anyHabitatProblem;
  List<Alternative> alternatives;
  String consciousConsumption;
  String marketResearch;

  InvoiceAnalysis({
    required this.whichItemsBought,
    required this.anyHealthProblem,
    required this.anyHabitatProblem,
    required this.alternatives,
    required this.consciousConsumption,
    required this.marketResearch,
  });

  factory InvoiceAnalysis.fromJson(final Map<String, dynamic> json) {
    return InvoiceAnalysis(
      whichItemsBought: (json['which_items_bought'] as List?)?.map((final i) => Item.fromJson(i)).toList() ?? [],
      anyHealthProblem: json['any_health_problem'] ?? '',
      anyHabitatProblem: json['any_habitat problem'] ?? '',
      alternatives: (json['alternatives'] as List?)?.map((final i) => Alternative.fromJson(i)).toList() ?? [],
      consciousConsumption: json['conscious_consumption'] ?? '',
      marketResearch: json['market_research'] ?? '',
    );
  }
}

class Item {
  String name;
  String price;

  Item({
    required this.name,
    required this.price,
  });

  factory Item.fromJson(final Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      price: json['price'],
    );
  }
}

class Alternative {
  String name;
  String description;

  Alternative({
    required this.name,
    required this.description,
  });

  factory Alternative.fromJson(final Map<String, dynamic> json) {
    return Alternative(
      name: json['name'],
      description: json['description'],
    );
  }
}
