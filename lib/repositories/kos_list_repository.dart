class KosListItem {
  const KosListItem({
    required this.id,
    required this.name,
    required this.address,
    required this.monthlyPrice,
    required this.isActive,
    this.facilities = const [],
  });

  final String id;
  final String name;
  final String address;
  final int monthlyPrice;
  final bool isActive;
  final List<String> facilities;
}

enum KosSortOrder { newest, cheapest }

abstract class KosListRepository {
  Future<List<KosListItem>> fetchActiveKos();
}

extension KosListRepositorySearch on KosListRepository {
  Future<List<KosListItem>> searchActiveKos(String query) async {
    final normalizedQuery = query.trim().toLowerCase();
    final kosList = await fetchActiveKos();
    if (normalizedQuery.isEmpty) {
      return kosList;
    }

    return kosList
        .where(
          (kos) =>
              kos.name.toLowerCase().contains(normalizedQuery) ||
              kos.address.toLowerCase().contains(normalizedQuery),
        )
        .toList(growable: false);
  }
}

extension KosListRepositorySorting on KosListRepository {
  List<KosListItem> sortKos(List<KosListItem> items, KosSortOrder order) {
    final sortedItems = List<KosListItem>.of(items);
    if (order == KosSortOrder.cheapest) {
      sortedItems.sort((first, second) {
        return first.monthlyPrice.compareTo(second.monthlyPrice);
      });
    }
    return List.unmodifiable(sortedItems);
  }
}
