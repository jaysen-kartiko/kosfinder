import 'package:flutter/material.dart';

import '../models/kos.dart';
import '../providers/my_kos_provider.dart';
import '../repositories/kos_management_repository.dart';
import '../repositories/my_kos_repository.dart';
import 'kos_form_screen.dart';

class MyKosScreen extends StatefulWidget {
  const MyKosScreen({
    super.key,
    required this.ownerId,
    required this.repository,
    required this.managementRepository,
  });

  final String ownerId;
  final MyKosRepository repository;
  final KosManagementRepository managementRepository;

  @override
  State<MyKosScreen> createState() => _MyKosScreenState();
}

class _MyKosScreenState extends State<MyKosScreen> {
  final Set<String> _busyKosIds = {};
  String? _actionError;
  Kos? _failedHideKos;
  late final MyKosProvider _provider = MyKosProvider(
    widget.repository,
    ownerId: widget.ownerId,
  );

  @override
  void initState() {
    super.initState();
    _provider.load();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _openForm({Kos? kos}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => KosFormScreen(
          repository: widget.managementRepository,
          kos: kos,
        ),
      ),
    );
    if (saved == true) {
      if (mounted) {
        setState(() {
          _actionError = null;
          _failedHideKos = null;
        });
      }
      await _provider.load();
    }
  }

  Future<void> _hideKos(Kos kos) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sembunyikan kos?'),
        content: Text('Kos "${kos.name}" tidak akan tampil pada pencarian.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: ValueKey('confirm-hide-${kos.id}'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sembunyikan'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    await _performHideKos(kos);
  }

  Future<void> _performHideKos(Kos kos) async {
    setState(() {
      _busyKosIds.add(kos.id);
      _actionError = null;
      _failedHideKos = null;
    });
    try {
      await widget.managementRepository.hideKos(
        kosId: kos.id,
        ownerId: widget.ownerId,
      );
      await _provider.load();
    } on KosManagementException catch (error) {
      if (mounted) {
        setState(() {
          _actionError = error.message;
          _failedHideKos = kos;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _busyKosIds.remove(kos.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Kos Saya')),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add-kos'),
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kos'),
      ),
      body: AnimatedBuilder(
        animation: _provider,
        builder: (context, _) {
          if (_provider.isLoading || _provider.status == MyKosStatus.idle) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_provider.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_provider.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _provider.retry,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (_provider.isEmpty) {
            return const Center(child: Text('Belum ada kos milik Anda.'));
          }
          return Column(
            children: [
              if (_actionError case final message?)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          key: const ValueKey('kos-action-error'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                      if (_failedHideKos case final failedKos?)
                        TextButton(
                          key: const ValueKey('retry-hide-kos'),
                          onPressed: _busyKosIds.contains(failedKos.id)
                              ? null
                              : () => _performHideKos(failedKos),
                          child: const Text('Coba lagi'),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _provider.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final kos = _provider.items[index];
                    return Card(
                      child: ListTile(
                        key: ValueKey('my-kos-${kos.id}'),
                        title: Text(kos.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(kos.address),
                            const SizedBox(height: 4),
                            Text(
                              '${_formatRupiah(kos.monthlyPrice.round())} / bulan',
                            ),
                            Text(kos.isActive ? 'Aktif' : 'Nonaktif'),
                          ],
                        ),
                        trailing: _busyKosIds.contains(kos.id)
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : PopupMenuButton<String>(
                                key: ValueKey('kos-actions-${kos.id}'),
                                onSelected: (action) {
                                  if (action == 'edit') {
                                    _openForm(kos: kos);
                                  } else if (action == 'hide') {
                                    _hideKos(kos);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Ubah'),
                                  ),
                                  if (kos.isActive)
                                    const PopupMenuItem(
                                      value: 'hide',
                                      child: Text('Sembunyikan'),
                                    ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
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
