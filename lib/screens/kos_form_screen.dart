import 'package:flutter/material.dart';

import '../models/kos.dart';
import '../providers/kos_form_provider.dart';
import '../repositories/kos_management_repository.dart';

class KosFormScreen extends StatefulWidget {
  const KosFormScreen({
    super.key,
    required this.repository,
    this.kos,
  });

  final KosManagementRepository repository;
  final Kos? kos;

  @override
  State<KosFormScreen> createState() => _KosFormScreenState();
}

class _KosFormScreenState extends State<KosFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.kos?.name ?? '',
  );
  late final _addressController = TextEditingController(
    text: widget.kos?.address ?? '',
  );
  late final _phoneController = TextEditingController(
    text: widget.kos?.phone ?? '',
  );
  late final _priceController = TextEditingController(
    text: widget.kos?.monthlyPrice.toStringAsFixed(0) ?? '',
  );
  late final _descriptionController = TextEditingController(
    text: widget.kos?.description ?? '',
  );
  late bool _isActive = widget.kos?.isActive ?? true;
  late final KosFormProvider _provider = KosFormProvider(
    widget.repository,
    initialKos: widget.kos,
  );

  @override
  void initState() {
    super.initState();
    _provider.loadFacilities();
  }

  @override
  void dispose() {
    _provider.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  KosFormData _formData() {
    return KosFormData(
      name: _nameController.text,
      address: _addressController.text,
      phone: _phoneController.text,
      monthlyPrice: _priceController.text,
      description: _descriptionController.text,
      isActive: _isActive,
    );
  }

  String? _validateField(String field) => validateKosForm(_formData())[field];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final saved = await _provider.save(_formData());
    if (saved && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kos == null ? 'Tambah Kos' : 'Ubah Kos'),
      ),
      body: AnimatedBuilder(
        animation: _provider,
        builder: (context, _) {
          if (_provider.isLoadingFacilities) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_provider.hasLoadError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _provider.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _provider.loadFacilities,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                TextFormField(
                  key: const ValueKey('kos-name'),
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama kos'),
                  textInputAction: TextInputAction.next,
                  validator: (_) => _validateField('name'),
                ),
                TextFormField(
                  key: const ValueKey('kos-address'),
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                  maxLines: 2,
                  textInputAction: TextInputAction.next,
                  validator: (_) => _validateField('address'),
                ),
                TextFormField(
                  key: const ValueKey('kos-phone'),
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor telepon',
                    hintText: '08xxxxxxxxxx',
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (_) => _validateField('phone'),
                ),
                TextFormField(
                  key: const ValueKey('kos-price'),
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Harga per bulan (Rp)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (_) => _validateField('monthlyPrice'),
                ),
                TextFormField(
                  key: const ValueKey('kos-description'),
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  maxLines: 4,
                  validator: (_) => _validateField('description'),
                ),
                const SizedBox(height: 16),
                Text('Fasilitas', style: Theme.of(context).textTheme.titleMedium),
                if (_provider.facilities.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Belum ada fasilitas yang tersedia.'),
                  ),
                for (final facility in _provider.facilities)
                  CheckboxListTile(
                    key: ValueKey('facility-${facility.id}'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(facility.name),
                    value: _provider.selectedFacilityIds.contains(facility.id),
                    onChanged: (selected) => _provider.toggleFacility(
                      facility.id,
                      selected ?? false,
                    ),
                  ),
                SwitchListTile(
                  key: const ValueKey('kos-active'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Kos aktif'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
                if (_provider.errorMessage case final message?) ...[
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  key: const ValueKey('kos-save'),
                  onPressed: _provider.isSaving ? null : _submit,
                  child: _provider.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _provider.errorMessage == null
                              ? 'Simpan'
                              : 'Coba lagi',
                        ),
                ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
