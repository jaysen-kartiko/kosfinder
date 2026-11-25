import 'package:flutter/material.dart';

import '../providers/kos_detail_provider.dart';
import '../providers/kos_list_provider.dart';
import '../repositories/kos_list_repository.dart';
import 'kos_detail_screen.dart';

class KosListScreen extends StatefulWidget {
  const KosListScreen({
    super.key,
    required this.provider,
    required this.loadKos,
    this.onProfile,
  });

  final KosListProvider provider;
  final KosDetailLoader loadKos;
  final VoidCallback? onProfile;

  @override
  State<KosListScreen> createState() => _KosListScreenState();
}

class _KosListScreenState extends State<KosListScreen> {
  final _priceFormKey = GlobalKey<FormState>();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _searchController = TextEditingController();
  String? _priceRangeError;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.provider.searchQuery;
    widget.provider.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    if (!widget.provider.isLoading) {
      widget.provider.search(_searchController.text);
    }
  }

  void _resetSearch() {
    _searchController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    _priceRangeError = null;
    _priceFormKey.currentState?.reset();
    widget.provider.resetSearch();
  }

  void _applyPriceFilter() {
    if (!_priceFormKey.currentState!.validate()) {
      return;
    }

    final minPrice = int.tryParse(_minPriceController.text.trim());
    final maxPrice = int.tryParse(_maxPriceController.text.trim());
    if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
      setState(() {
        _priceRangeError = 'Harga minimum tidak boleh melebihi maksimum.';
      });
      return;
    }

    setState(() {
      _priceRangeError = null;
    });
    widget.provider.setFilters(
      facilities: widget.provider.selectedFacilities,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  void _toggleFacility(String facility, bool selected) {
    final facilities = Set<String>.of(widget.provider.selectedFacilities);
    if (selected) {
      facilities.add(facility);
    } else {
      facilities.remove(facility);
    }
    widget.provider.setFilters(
      facilities: facilities,
      minPrice: widget.provider.minPrice,
      maxPrice: widget.provider.maxPrice,
    );
  }

  void _clearFilters() {
    _minPriceController.clear();
    _maxPriceController.clear();
    _priceRangeError = null;
    _priceFormKey.currentState?.reset();
    widget.provider.clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kos'),
        actions: [
          if (widget.onProfile != null)
            IconButton(
              key: const ValueKey('open-profile'),
              onPressed: widget.onProfile,
              tooltip: 'Profil',
              icon: const Icon(Icons.account_circle_outlined),
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.provider,
        builder: (context, _) {
          return Column(
            children: [
              _buildSearchPanel(),
              Expanded(
                child:
                    widget.provider.isLoading ||
                        widget.provider.status == KosListStatus.idle
                    ? const Center(child: CircularProgressIndicator())
                    : widget.provider.hasError
                    ? _MessageState(
                        icon: Icons.cloud_off,
                        message: widget.provider.errorMessage!,
                        actionLabel: 'Coba lagi',
                        onAction: widget.provider.retry,
                      )
                    : _buildKosList(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          TextField(
            key: const ValueKey('kos-search-input'),
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              labelText: 'Cari kos',
              hintText: 'Nama atau area',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submitSearch(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                key: const ValueKey('kos-search-reset'),
                onPressed: widget.provider.isLoading ? null : _resetSearch,
                child: const Text('Reset pencarian'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                key: const ValueKey('kos-search-submit'),
                onPressed: widget.provider.isLoading ? null : _submitSearch,
                icon: const Icon(Icons.search),
                label: const Text('Cari'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKosList(BuildContext context) {
    final items = widget.provider.items;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFilterPanel(context),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Urutkan'),
              DropdownButton<KosSortOrder>(
                key: const ValueKey('kos-sort-order'),
                value: widget.provider.sortOrder,
                items: const [
                  DropdownMenuItem(
                    value: KosSortOrder.newest,
                    child: Text('Terbaru'),
                  ),
                  DropdownMenuItem(
                    value: KosSortOrder.cheapest,
                    child: Text('Harga termurah'),
                  ),
                ],
                onChanged: (order) {
                  if (order != null) {
                    widget.provider.setSortOrder(order);
                  }
                },
              ),
            ],
          ),
        ),
        if (items.isEmpty) ...[
          const SizedBox(height: 12),
          _MessageState(
            icon: Icons.search_off,
            message:
                widget.provider.hasActiveFilters ||
                    widget.provider.searchQuery.isNotEmpty
                ? 'Tidak ada kos yang cocok dengan pencarian atau filter ini.'
                : 'Belum ada kos yang tersedia.',
            actionLabel:
                widget.provider.hasActiveFilters ||
                    widget.provider.searchQuery.isNotEmpty
                ? 'Reset pencarian'
                : null,
            onAction:
                widget.provider.hasActiveFilters ||
                    widget.provider.searchQuery.isNotEmpty
                ? _resetSearch
                : null,
          ),
        ] else ...[
          for (final item in items) ...[
            const SizedBox(height: 8),
            _buildKosCard(context, item),
          ],
        ],
      ],
    );
  }

  Widget _buildFilterPanel(BuildContext context) {
    final facilities = widget.provider.availableFacilities;
    return Card(
      child: ExpansionTile(
        title: const Text('Filter harga dan fasilitas'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Form(
              key: _priceFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const ValueKey('min-price-filter'),
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Harga minimum (Rp)',
                          ),
                          validator: _validatePrice,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          key: const ValueKey('max-price-filter'),
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Harga maksimum (Rp)',
                          ),
                          validator: _validatePrice,
                        ),
                      ),
                    ],
                  ),
                  if (_priceRangeError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _priceRangeError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      onPressed: _applyPriceFilter,
                      child: const Text('Terapkan harga'),
                    ),
                  ),
                  const Divider(),
                  Text(
                    'Fasilitas',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (facilities.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Belum ada fasilitas untuk difilter.'),
                    )
                  else
                    for (final facility in facilities)
                      CheckboxListTile(
                        key: ValueKey('facility-$facility'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(facility),
                        value: widget.provider.selectedFacilities.contains(
                          facility,
                        ),
                        onChanged: (selected) {
                          _toggleFacility(facility, selected ?? false);
                        },
                      ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Hapus semua filter'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validatePrice(String? input) {
    if (input == null || input.trim().isEmpty) {
      return null;
    }
    final price = int.tryParse(input.trim());
    if (price == null || price < 0) {
      return 'Masukkan angka harga yang valid.';
    }
    return null;
  }

  Widget _buildKosCard(BuildContext context, KosListItem item) {
    return Card(
      child: ListTile(
        key: ValueKey('kos-${item.id}'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(item.name),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.address),
              const SizedBox(height: 4),
              Text(
                '${_formatRupiah(item.monthlyPrice)} / bulan',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              const Chip(
                label: Text('Aktif'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => KosDetailScreen(
                kosId: item.id,
                provider: KosDetailProvider(widget.loadKos),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatRupiah(int amount) {
  final digits = amount.toString();
  final grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return 'Rp$grouped,-';
}
