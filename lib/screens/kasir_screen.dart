import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/kasir_log_controller.dart';
import '../controllers/settings_controller.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';
import '../widgets/receipt_dialog.dart';

class KasirScreen extends StatelessWidget {
  const KasirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final productC = Get.find<ProductController>();
    final categoryC = Get.find<CategoryController>();
    final txC = Get.find<TransactionController>();
    final settingsC = Get.find<SettingsController>();

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 760;

    if (isMobile) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppTheme.bg,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Obx(() {
              final user = auth.currentUser.value;
              return Text(
                'Kasir: ${user?.nama ?? "-"}',
                overflow: TextOverflow.ellipsis,
              );
            }),
            actions: [
              IconButton(
                onPressed: () {
                  Get.dialog(_KasirLogDialog());
                },
                icon: const Icon(Icons.note_alt_outlined),
                tooltip: 'Catat',
              ),
              IconButton(
                onPressed: auth.logout,
                icon: const Icon(Icons.logout),
                tooltip: 'Keluar',
              ),
            ],
            bottom: TabBar(
              labelColor: AppTheme.text,
              unselectedLabelColor: AppTheme.text2,
              indicatorColor: AppTheme.text,
              tabs: [
                const Tab(
                  icon: Icon(Icons.inventory_2_outlined),
                  text: 'Produk',
                ),
                Obx(
                  () => Tab(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    text: 'Keranjang (${txC.totalItems})',
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _ProductPanel(
                productC: productC,
                categoryC: categoryC,
                txC: txC,
                isMobile: true,
              ),
              _CartPanel(
                txC: txC,
                settingsC: settingsC,
                isMobile: true,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Obx(() {
          final user = auth.currentUser.value;
          return Text('TokoKu POS — Kasir: ${user?.nama ?? "-"}');
        }),
        actions: [
          TextButton.icon(
            onPressed: () {
              Get.dialog(_KasirLogDialog());
            },
            icon: const Icon(Icons.note_alt_outlined),
            label: const Text('Catat'),
          ),
          TextButton(
            onPressed: auth.logout,
            child: const Text('Keluar'),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: _ProductPanel(
              productC: productC,
              categoryC: categoryC,
              txC: txC,
              isMobile: false,
            ),
          ),
          SizedBox(
            width: 380,
            child: _CartPanel(
              txC: txC,
              settingsC: settingsC,
              isMobile: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductPanel extends StatelessWidget {
  final ProductController productC;
  final CategoryController categoryC;
  final TransactionController txC;
  final bool isMobile;

  const _ProductPanel({
    required this.productC,
    required this.categoryC,
    required this.txC,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Cari produk...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              productC.searchQuery.value = value;
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: Obx(() {
              final cats = categoryC.categories;

              return ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryChip(
                    label: 'Semua',
                    active: productC.selectedCategory.value == 'Semua',
                    onTap: () {
                      productC.selectedCategory.value = 'Semua';
                    },
                  ),
                  const SizedBox(width: 8),
                  ...cats.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CategoryChip(
                        label: '${c.emoji} ${c.nama}',
                        active: productC.selectedCategory.value == c.nama,
                        onTap: () {
                          productC.selectedCategory.value = c.nama;
                        },
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              final products = productC.filteredProducts;

              if (products.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada produk',
                    style: TextStyle(color: AppTheme.text2),
                  ),
                );
              }

              final width = MediaQuery.of(context).size.width;

              int crossAxisCount;
              double childAspectRatio;

              if (width < 380) {
                crossAxisCount = 1;
                childAspectRatio = 2.35;
              } else if (width < 760) {
                crossAxisCount = 2;
                childAspectRatio = 0.88;
              } else if (width > 1000) {
                crossAxisCount = 4;
                childAspectRatio = 1.05;
              } else {
                crossAxisCount = 3;
                childAspectRatio = 1.0;
              }

              return GridView.builder(
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (context, index) {
                  final p = products[index];

                  return InkWell(
                    onTap: () {
                      txC.addToCart(p);

                      if (isMobile) {
                        Get.snackbar(
                          'Ditambahkan',
                          '${p.nama} masuk keranjang',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(milliseconds: 900),
                        );
                      }
                    },
                    borderRadius: AppTheme.radiusLarge,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: AppTheme.radiusLarge,
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: isMobile && width < 380
                          ? Row(
                              children: [
                                Text(
                                  p.emoji,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _ProductInfo(product: p),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.emoji,
                                  style: const TextStyle(fontSize: 34),
                                ),
                                const Spacer(),
                                _ProductInfo(product: p),
                              ],
                            ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final dynamic product;

  const _ProductInfo({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.nama,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppTheme.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          product.kategori,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.text2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          Formatter.rupiah(product.hargaSetelahDiskon),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Stok ${product.stok}',
          style: TextStyle(
            fontSize: 12,
            color: product.stok <= 5 ? AppTheme.red : AppTheme.text2,
          ),
        ),
      ],
    );
  }
}

class _CartPanel extends StatelessWidget {
  final TransactionController txC;
  final SettingsController settingsC;
  final bool isMobile;

  const _CartPanel({
    required this.txC,
    required this.settingsC,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: isMobile
            ? null
            : const Border(
                left: BorderSide(
                  color: AppTheme.border,
                ),
              ),
      ),
      child: isMobile
          ? _buildMobileLayout(context)
          : _buildDesktopLayout(context),
    );
  }

  // ============================================================
  // MOBILE
  // Seluruh keranjang dan pembayaran dibuat menjadi satu ListView.
  // Dengan begitu, saat keyboard muncul semua bagian bisa bergeser.
  // ============================================================
  Widget _buildMobileLayout(BuildContext context) {
    return ListView(
      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,

      // Scaffold sudah memakai resizeToAvoidBottomInset: true.
      // Jadi tidak perlu menambahkan viewInsets.bottom lagi.
      padding: const EdgeInsets.only(
        bottom: 24,
      ),

      children: [
        _buildHeader(),

        Obx(() {
          if (txC.cart.isEmpty) {
            return const SizedBox(
              height: 110,
              child: Center(
                child: Text(
                  'Belum ada item.\n'
                  'Buka tab Produk lalu pilih barang.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.text2,
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(10),
            itemCount: txC.cart.length,
            separatorBuilder: (_, __) {
              return const SizedBox(height: 8);
            },
            itemBuilder: (context, index) {
              final item = txC.cart[index];

              return _MobileCartItem(
                item: item,
                txC: txC,
              );
            },
          );
        }),

        _buildPaymentPanel(context),
      ],
    );
  }

  // ============================================================
  // DESKTOP
  // Keranjang tetap menggunakan Expanded karena tidak bermasalah
  // dengan keyboard Android.
  // ============================================================
  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),

        Expanded(
          child: Obx(() {
            if (txC.cart.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada item.\n'
                  'Pilih produk di panel kiri.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.text2,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: txC.cart.length,
              separatorBuilder: (_, __) {
                return const SizedBox(height: 8);
              },
              itemBuilder: (context, index) {
                final item = txC.cart[index];

                return _DesktopCartItem(
                  item: item,
                  txC: txC,
                );
              },
            );
          }),
        ),

        SafeArea(
          top: false,
          child: _buildPaymentPanel(context),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER KERANJANG
  // ============================================================
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(
        isMobile ? 12 : 16,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.border,
          ),
        ),
      ),
      child: Obx(
        () => Row(
          children: [
            const Text(
              'Keranjang',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.text,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surface2,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                '${txC.totalItems} item',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.text2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PANEL PEMBAYARAN
  // ============================================================
  Widget _buildPaymentPanel(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isMobile ? 12 : 16,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.border,
          ),
        ),
      ),
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SummaryRow(
              label: 'Subtotal',
              value: Formatter.rupiah(
                txC.subtotal,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,

              // Membantu field tetap terlihat saat keyboard muncul.
              scrollPadding: const EdgeInsets.only(
                bottom: 180,
              ),

              decoration: const InputDecoration(
                labelText: 'Diskon (Rp)',
              ),
              onChanged: txC.setDiscount,
              onSubmitted: (_) {
                FocusScope.of(context).unfocus();
              },
            ),

            const SizedBox(height: 8),

            _SummaryRow(
              label: 'Diskon',
              value:
                  '- ${Formatter.rupiah(txC.discount.value)}',
              valueColor: AppTheme.red,
            ),

            const Divider(
              height: 24,
            ),

            _SummaryRow(
              label: 'Total',
              value: Formatter.rupiah(
                txC.total,
              ),
              bold: true,
            ),

            const SizedBox(height: 12),

            const Row(
              children: [
                _PayButton('Tunai'),
                SizedBox(width: 8),
                _PayButton('QRIS'),
                SizedBox(width: 8),
                _PayButton('Transfer'),
              ],
            ),

            const SizedBox(height: 12),

            if (txC.paymentMethod.value == 'Tunai') ...[
              TextField(
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,

                // Membuat jumlah bayar otomatis naik di atas keyboard.
                scrollPadding: const EdgeInsets.only(
                  bottom: 220,
                ),

                decoration: const InputDecoration(
                  labelText: 'Jumlah bayar',
                ),
                onChanged: txC.setCash,
                onSubmitted: (_) {
                  FocusScope.of(context).unfocus();
                },
              ),

              const SizedBox(height: 8),

              _SummaryRow(
                label: 'Kembalian',
                value: Formatter.rupiah(
                  txC.change < 0
                      ? 0
                      : txC.change,
                ),
                valueColor: AppTheme.green,
              ),
            ],

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();

                  final transaction =
                      txC.processTransaction();

                  if (transaction != null) {
                    Get.dialog(
                      ReceiptDialog(
                        transaction: transaction,
                        settings:
                            settingsC.settings.value,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.text,
                  foregroundColor: AppTheme.surface,
                ),
                child: const Text(
                  'Proses Transaksi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileCartItem extends StatelessWidget {
  final dynamic item;
  final TransactionController txC;

  const _MobileCartItem({
    required this.item,
    required this.txC,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: AppTheme.radius,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                item.product.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.product.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text,
                  ),
                ),
              ),
              Text(
                Formatter.rupiah(item.total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                Formatter.rupiah(item.harga),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.text2,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  txC.decreaseItem(item.product.id);
                },
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '${item.qty}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  txC.addToCart(item.product);
                },
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DesktopCartItem extends StatelessWidget {
  final dynamic item;
  final TransactionController txC;

  const _DesktopCartItem({
    required this.item,
    required this.txC,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: AppTheme.radius,
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Text(
            item.product.emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Formatter.rupiah(item.harga),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.text2,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              txC.decreaseItem(item.product.id);
            },
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text(
            '${item.qty}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {
              txC.addToCart(item.product);
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
          Text(
            Formatter.rupiah(item.total),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.text,
      labelStyle: TextStyle(
        color: active ? AppTheme.surface : AppTheme.text2,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: AppTheme.surface,
      side: const BorderSide(color: AppTheme.border),
    );
  }
}

class _PayButton extends StatelessWidget {
  final String label;

  const _PayButton(this.label);

  @override
  Widget build(BuildContext context) {
    final txC = Get.find<TransactionController>();

    return Expanded(
      child: Obx(
        () {
          final active = txC.paymentMethod.value == label;

          return OutlinedButton(
            onPressed: () => txC.setPayment(label),
            style: OutlinedButton.styleFrom(
              backgroundColor: active ? AppTheme.text : AppTheme.surface,
              foregroundColor: active ? AppTheme.surface : AppTheme.text2,
            ),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.text2,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.text,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            fontSize: bold ? 18 : 14,
          ),
        ),
      ],
    );
  }
}

class _KasirLogDialog extends StatelessWidget {
  _KasirLogDialog();

  final TextEditingController descC = TextEditingController();
  final TextEditingController jumlahC = TextEditingController();
  final RxBool isSaving = false.obs;

  @override
  Widget build(BuildContext context) {
    final logC = Get.find<KasirLogController>();

    return AlertDialog(
      title: const Text('Catat Pengeluaran Kasir'),
      content: SizedBox(
        width: 420,
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _KasirTypeChip(label: '🏪 Modal', type: 'modal'),
                  _KasirTypeChip(label: '💳 Kasbon', type: 'kasbon'),
                  _KasirTypeChip(label: '🎁 Bonus', type: 'bonus'),
                  _KasirTypeChip(label: '📋 Lain', type: 'lain'),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surface2,
                  borderRadius: AppTheme.radius,
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  '${logC.getTypeEmoji(logC.selectedType.value)} ${logC.getTypeLabel(logC.selectedType.value)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descC,
                enabled: !isSaving.value,
                decoration: const InputDecoration(
                  labelText: 'Keterangan',
                  hintText: 'Misal: Kasbon Budi, beli stok rokok...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: jumlahC,
                enabled: !isSaving.value,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  hintText: 'Contoh: 10000 atau 10.000',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Obx(
          () => TextButton(
            onPressed: isSaving.value ? null : () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
        ),
        Obx(
          () => ElevatedButton(
            onPressed: isSaving.value
                ? null
                : () {
                    isSaving.value = true;

                    final success = logC.addLog(
                      desc: descC.text,
                      jumlahText: jumlahC.text,
                    );

                    if (success) {
                      Navigator.of(context).pop();
                    } else {
                      isSaving.value = false;
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.text,
              foregroundColor: AppTheme.surface,
            ),
            child: isSaving.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Simpan'),
          ),
        ),
      ],
    );
  }
}

class _KasirTypeChip extends StatelessWidget {
  final String label;
  final String type;

  const _KasirTypeChip({
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final logC = Get.find<KasirLogController>();

    return Obx(() {
      final active = logC.selectedType.value == type;

      return ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => logC.selectType(type),
        selectedColor: AppTheme.text,
        backgroundColor: AppTheme.surface,
        side: const BorderSide(color: AppTheme.border),
        labelStyle: TextStyle(
          color: active ? AppTheme.surface : AppTheme.text2,
          fontWeight: FontWeight.w600,
        ),
      );
    });
  }
}