import 'package:flutter/material.dart';

import '../providers/kos_detail_provider.dart';

class KosDetailScreen extends StatefulWidget {
  const KosDetailScreen({
    super.key,
    required this.kosId,
    required this.provider,
  });

  final String kosId;
  final KosDetailProvider provider;

  @override
  State<KosDetailScreen> createState() => _KosDetailScreenState();
}

class _KosDetailScreenState extends State<KosDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.provider.load(widget.kosId);
  }

  @override
  void dispose() {
    widget.provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kos')),
      body: AnimatedBuilder(
        animation: widget.provider,
        builder: (context, _) {
          final provider = widget.provider;
          if (provider.isLoading || provider.status == KosDetailStatus.idle) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.hasError) {
            return _DetailMessage(
              icon: Icons.cloud_off,
              message: provider.errorMessage!,
              actionLabel: 'Coba lagi',
              onAction: () => provider.retry(widget.kosId),
            );
          }
          if (provider.isUnavailable) {
            return _DetailMessage(
              icon: Icons.home_work_outlined,
              message: 'Kos tidak tersedia.',
              actionLabel: 'Kembali ke daftar',
              onAction: () => Navigator.of(context).maybePop(),
            );
          }

          final kos = provider.kos!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(kos.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              _DetailLine(label: 'Alamat', value: kos.address),
              _DetailLine(label: 'Telepon', value: kos.phone),
              _DetailLine(
                label: 'Harga bulanan',
                value: '${_formatRupiah(kos.monthlyPrice.round())} / bulan',
              ),
              _DetailLine(label: 'Deskripsi', value: kos.description),
              _DetailLine(
                label: 'Fasilitas',
                value: kos.facilities.isEmpty
                    ? 'Belum ada fasilitas tercatat.'
                    : kos.facilities.join(', '),
              ),
              const SizedBox(height: 16),
              Text(
                'Tipe kamar',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (kos.roomTypes.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Belum ada tipe kamar tercatat.'),
                )
              else
                ...kos.roomTypes.map(
                  (room) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(room.name),
                    subtitle: Text(
                      '${_formatRupiah(room.monthlyPrice.round())} / bulan',
                    ),
                    trailing: Text(room.isAvailable ? 'Tersedia' : 'Penuh'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 2),
          Text(value),
        ],
      ),
    );
  }
}

class _DetailMessage extends StatelessWidget {
  const _DetailMessage({
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
