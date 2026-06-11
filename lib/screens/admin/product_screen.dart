import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/category_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/admin_scaffold.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();

    return AdminScaffold(
      title: 'Daftar Barang',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Cari barang...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      productController.searchQuery.value = value;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final saved = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const _ProductDialog(),
                    );

                    if (saved == true) {
                      Get.snackbar(
                        'Berhasil',
                        'Barang berhasil ditambahkan',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.text,
                    foregroundColor: AppTheme.surface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final products = productController.filteredProducts;

                if (products.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada barang',
                      style: TextStyle(color: AppTheme.text2),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, __) {
                    return const SizedBox(height: 10);
                  },
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: AppTheme.radiusLarge,
                        border: Border.all(
                          color: AppTheme.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            product.emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.nama,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.text,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${product.kode} • ${product.kategori}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.text2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Beli: ${Formatter.rupiah(product.hargaBeli)} '
                                  '| Jual: ${Formatter.rupiah(product.hargaJual)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.text2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Stok ${product.stok}',
                                style: TextStyle(
                                  color: product.stok <= 5
                                      ? AppTheme.red
                                      : AppTheme.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      final saved =
                                          await showDialog<bool>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (_) {
                                          return _ProductDialog(
                                            product: product,
                                          );
                                        },
                                      );

                                      if (saved == true) {
                                        Get.snackbar(
                                          'Berhasil',
                                          'Barang berhasil diperbarui',
                                          snackPosition:
                                              SnackPosition.BOTTOM,
                                        );
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      productController.deleteProduct(
                                        product.id,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: AppTheme.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final ProductModel? product;

  const _ProductDialog({
    this.product,
  });

  @override
  State<_ProductDialog> createState() {
    return _ProductDialogState();
  }
}

class _ProductDialogState extends State<_ProductDialog> {
  late final TextEditingController kodeController;
  late final TextEditingController namaController;
  late final TextEditingController emojiController;
  late final TextEditingController hargaBeliController;
  late final TextEditingController hargaJualController;
  late final TextEditingController stokController;

  late String selectedCategory;

  bool isSaving = false;

  ProductController get productController {
    return Get.find<ProductController>();
  }

  CategoryController get categoryController {
    return Get.find<CategoryController>();
  }

  List<String> get categoryNames {
    final names = categoryController.categories
        .map((category) => category.nama)
        .toSet()
        .toList();

    if (names.isEmpty) {
      names.add('Lainnya');
    }

    return names;
  }

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    kodeController = TextEditingController(
      text: product?.kode ?? '',
    );

    namaController = TextEditingController(
      text: product?.nama ?? '',
    );

    emojiController = TextEditingController(
      text: product?.emoji ?? '📦',
    );

    hargaBeliController = TextEditingController(
      text: product == null
          ? ''
          : product.hargaBeli.toString(),
    );

    hargaJualController = TextEditingController(
      text: product == null
          ? ''
          : product.hargaJual.toString(),
    );

    stokController = TextEditingController(
      text: product == null
          ? ''
          : product.stok.toString(),
    );

    final names = categoryNames;

    selectedCategory = names.contains(product?.kategori)
        ? product!.kategori
        : names.first;
  }

  @override
  void dispose() {
    kodeController.dispose();
    namaController.dispose();
    emojiController.dispose();
    hargaBeliController.dispose();
    hargaJualController.dispose();
    stokController.dispose();

    super.dispose();
  }

  void _save() {
    if (isSaving) return;

    final kode = kodeController.text.trim();
    final nama = namaController.text.trim();

    final emoji = emojiController.text.trim().isEmpty
        ? '📦'
        : emojiController.text.trim();

    final hargaBeli = int.tryParse(
          hargaBeliController.text,
        ) ??
        0;

    final hargaJual = int.tryParse(
          hargaJualController.text,
        ) ??
        0;

    final stok = int.tryParse(
          stokController.text,
        ) ??
        0;

    if (kode.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Kode barang wajib diisi',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (nama.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Nama barang wajib diisi',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (hargaJual <= 0) {
      Get.snackbar(
        'Gagal',
        'Harga jual harus lebih dari 0',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (hargaBeli < 0 || stok < 0) {
      Get.snackbar(
        'Gagal',
        'Harga beli dan stok tidak boleh negatif',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final product = ProductModel(
      id: widget.product?.id ??
          DateTime.now().microsecondsSinceEpoch,
      kode: kode,
      nama: nama,
      kategori: selectedCategory,
      hargaBeli: hargaBeli,
      hargaJual: hargaJual,
      stok: stok,
      emoji: emoji,
      diskon: widget.product?.diskon ?? 0,
    );

    final error = widget.product == null
        ? productController.addProduct(product)
        : productController.updateProduct(product);

    if (error != null) {
      setState(() {
        isSaving = false;
      });

      Get.snackbar(
        'Gagal',
        error,
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    FocusScope.of(context).unfocus();

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight =
        MediaQuery.of(context).viewInsets.bottom;

    final screenHeight =
        MediaQuery.of(context).size.height;

    final maxHeight = screenHeight -
        keyboardHeight -
        48;

    return Dialog(
      insetPadding: EdgeInsets.fromLTRB(
        16,
        24,
        16,
        keyboardHeight > 0 ? 12 : 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: maxHeight < 200 ? 200 : maxHeight,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                widget.product == null
                    ? 'Tambah Barang'
                    : 'Edit Barang',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.text,
                ),
              ),
              const SizedBox(height: 16),
              _ProductField(
                controller: kodeController,
                label: 'Kode Barang',
                enabled: !isSaving,
              ),
              const SizedBox(height: 10),
              _ProductField(
                controller: namaController,
                label: 'Nama Barang',
                enabled: !isSaving,
                textCapitalization:
                    TextCapitalization.words,
              ),
              const SizedBox(height: 10),
              _ProductField(
                controller: emojiController,
                label: 'Emoji',
                enabled: !isSaving,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                ),
                items: categoryNames.map((name) {
                  final category =
                      categoryController.categories
                          .firstWhereOrNull(
                    (item) => item.nama == name,
                  );

                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(
                      category == null
                          ? name
                          : '${category.emoji} $name',
                    ),
                  );
                }).toList(),
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value == null) return;

                        setState(() {
                          selectedCategory = value;
                        });
                      },
              ),
              const SizedBox(height: 10),
              _ProductField(
                controller: hargaBeliController,
                label: 'Harga Beli',
                enabled: !isSaving,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 10),
              _ProductField(
                controller: hargaJualController,
                label: 'Harga Jual',
                enabled: !isSaving,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 10),
              _ProductField(
                controller: stokController,
                label: 'Stok',
                enabled: !isSaving,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();

                            Navigator.of(context).pop(false);
                          },
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.text,
                      foregroundColor: AppTheme.surface,
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.surface,
                            ),
                          )
                        : const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  const _ProductField({
    required this.controller,
    required this.label,
    required this.enabled,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization =
        TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      scrollPadding: const EdgeInsets.only(
        bottom: 160,
      ),
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }
}