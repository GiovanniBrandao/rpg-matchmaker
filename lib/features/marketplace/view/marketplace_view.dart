// lib/features/marketplace/view/marketplace_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/partner_product_model.dart';

/// Marketplace de produtos de RPG de parceiros (venda via comissão/afiliado).
class MarketplaceView extends StatefulWidget {
  const MarketplaceView({super.key});

  @override
  State<MarketplaceView> createState() => _MarketplaceViewState();
}

class _MarketplaceViewState extends State<MarketplaceView> {
  ProductCategory _selectedCategory = ProductCategory.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final List<PartnerProductModel> _cart = [];
  final List<PartnerProductModel> _customPartnerProducts = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PartnerProductModel> get _filteredProducts {
    final all = [..._customPartnerProducts, ...PartnerProductModel.catalog];
    return all.where((p) {
      final matchesCat =
          _selectedCategory == ProductCategory.all || p.category == _selectedCategory;
      final q = _searchQuery.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.partnerName.toLowerCase().contains(q) ||
          p.system.toLowerCase().contains(q);
      return matchesCat && matchesQuery;
    }).toList();
  }

  double get _cartTotal => _cart.fold(0.0, (sum, p) => sum + p.price);
  double get _cartCommission => _cart.fold(0.0, (sum, p) => sum + p.commissionValue);

  void _addToCart(PartnerProductModel product) {
    HapticFeedback.lightImpact();
    setState(() {
      _cart.add(product);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${product.title}" adicionado à sacola!'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VER SACOLA',
          onPressed: _openCartSheet,
        ),
      ),
    );
  }

  void _openProductDetails(PartnerProductModel product) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: product.accentColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(product.icon, size: 36, color: product.accentColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                product.partnerName,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          product.partnerCity,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(product.description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              for (final h in product.highlights)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(h, style: theme.textTheme.bodySmall)),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              // Card de transparência de afiliado / comissão
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.handshake_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Parceria via Comissão (${product.commissionPercent}% • R\$ ${product.commissionValue.toStringAsFixed(2)})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            'Cupom parceiro: ${product.affiliateCoupon} (garante desconto e apoia sua mesa)',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: product.affiliateCoupon));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Cupom ${product.affiliateCoupon} copiado!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copiar'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.originalPrice != null)
                        Text(
                          'R\$ ${product.originalPrice!.toStringAsFixed(2)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      Text(
                        'R\$ ${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _addToCart(product);
                      },
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('Adicionar à Sacola'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCartSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sacola de Parceiros (${_cart.length})',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (_cart.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() => _cart.clear());
                          setModal(() {});
                        },
                        child: const Text('Limpar'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_cart.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('Sua sacola está vazia. Explore os itens dos parceiros!'),
                    ),
                  )
                else ...[
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _cart.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final item = _cart[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(item.icon, color: item.accentColor),
                          title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            '${item.partnerName} • Comissão: ${item.commissionPercent}%',
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'R\$ ${item.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                onPressed: () {
                                  setState(() => _cart.removeAt(i));
                                  setModal(() {});
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Comissão gerada p/ plataforma/mestre:'),
                      Text(
                        'R\$ ${_cartCommission.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total do Pedido:', style: theme.textTheme.titleMedium),
                      Text(
                        'R\$ ${_cartTotal.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      final total = _cartTotal;
                      final comm = _cartCommission;
                      setState(() => _cart.clear());
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Pedido enviado aos parceiros (R\$ ${total.toStringAsFixed(2)})! '
                            'Comissão registrada: R\$ ${comm.toStringAsFixed(2)}.',
                          ),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('FINALIZAR PEDIDO COM PARCEIROS'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Modal para lojas/criadores cadastrarem produto e simularem vendas via comissão.
  void _openPartnerPortalSheet() {
    final theme = Theme.of(context);
    final titleCtrl = TextEditingController();
    final storeCtrl = TextEditingController();
    double price = 120.0;
    int commission = 15;
    int monthlySales = 30;
    ProductCategory category = ProductCategory.dice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          final gross = price * monthlySales;
          final fee = gross * (commission / 100.0);
          final net = gross - fee;

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 4,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.storefront, color: theme.colorScheme.primary, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Portal de Parceiros & Comissão',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Anuncie dados, livros, miniaturas ou mapas digitais gratuitamente. '
                    'Você só paga uma comissão sobre as vendas realizadas pelo app.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 14),
                  // Simulador de Comissão Interativo
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Simulador de Repasse e Comissão',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('Preço: R\$ ${price.toStringAsFixed(0)}'),
                            ),
                            Text('Comissão: $commission%'),
                          ],
                        ),
                        Slider(
                          value: price,
                          min: 20,
                          max: 400,
                          divisions: 38,
                          label: 'R\$ ${price.toStringAsFixed(0)}',
                          onChanged: (v) => setModal(() => price = v),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text('Taxa de comissão (destaque):'),
                            ),
                            DropdownButton<int>(
                              value: commission,
                              underline: const SizedBox.shrink(),
                              items: const [10, 12, 15, 18, 20, 25]
                                  .map((c) => DropdownMenuItem(value: c, child: Text('$c%')))
                                  .toList(),
                              onChanged: (v) => setModal(() => commission = v ?? 15),
                            ),
                          ],
                        ),
                        const Divider(),
                        Text(
                          'Receita p/ $monthlySales vendas/mês: Você recebe R\$ ${net.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Comissão da plataforma/afiliados: R\$ ${fee.toStringAsFixed(2)} ($commission%)',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Publicar novo produto parceiro agora:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: storeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Loja ou Criador Parceiro',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Título do Produto de RPG',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<ProductCategory>(
                    initialValue: category,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: ProductCategory.values
                        .where((c) => c != ProductCategory.all)
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                        .toList(),
                    onChanged: (c) => setModal(() => category = c ?? ProductCategory.dice),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () {
                      final title = titleCtrl.text.trim();
                      final store = storeCtrl.text.trim();
                      if (title.isEmpty || store.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Preencha o nome da loja e o título do produto.'),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        _customPartnerProducts.insert(
                          0,
                          PartnerProductModel(
                            id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
                            title: title,
                            partnerName: store,
                            partnerCity: 'Parceiro Verificado • Comissão $commission%',
                            category: category,
                            system: 'Todos os Sistemas',
                            price: price,
                            commissionPercent: commission,
                            affiliateCoupon: 'PARCEIRO10',
                            rating: 5.0,
                            salesCount: 1,
                            description:
                                'Produto cadastrado via Portal de Parceiros com repasse automático de comissão ($commission%).',
                            highlights: [
                              'Parceiro oficial RPG Matchmaker',
                              'Suporte direto via chat da plataforma',
                            ],
                            icon: category.icon,
                            accentColor: const Color(0xFFD97706),
                          ),
                        );
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Produto "$title" publicado no Marketplace com $commission% de comissão!',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.publish),
                    label: const Text('PUBLICAR PRODUTO NO MARKETPLACE'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final products = _filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loja & Parceiros RPG'),
        actions: [
          IconButton(
            tooltip: 'Vender como Parceiro',
            icon: const Icon(Icons.handshake_outlined),
            onPressed: _openPartnerPortalSheet,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Sacola de Compras',
              onPressed: _openCartSheet,
              icon: Badge(
                isLabelVisible: _cart.isNotEmpty,
                label: Text('${_cart.length}'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Banner de Parceria & Comissão
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    const Color(0xFF5A3200),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 36),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marketplace Oficial de Parceiros',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Compre de lojas de RPG verificadas ou cadastre seus produtos via comissão (10% a 25%).',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: _openPartnerPortalSheet,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: const Color(0xFF261900),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text(
                      'Vender',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Busca rápida
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Buscar dados, livros, miniaturas, loja...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Chips de Categoria (IHC: Reconhecimento em vez de memorização)
            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: ProductCategory.values.length,
                itemBuilder: (_, index) {
                  final cat = ProductCategory.values[index];
                  final selected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: selected,
                      avatar: Icon(cat.icon, size: 16),
                      label: Text(cat.label),
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 6),

            // Lista de Produtos Parceiros
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum produto encontrado para "$_searchQuery".',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: products.length,
                      itemBuilder: (_, index) => _buildProductCard(products[index], theme),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(PartnerProductModel product, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openProductDetails(product),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone ilustrativo do produto com cor da categoria
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: product.accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(product.icon, size: 34, color: product.accentColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product.partnerName,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Comissão ${product.commissionPercent}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          '${product.rating} (${product.salesCount})',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '• ${product.system}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.originalPrice != null)
                                Text(
                                  'R\$ ${product.originalPrice!.toStringAsFixed(2)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 11,
                                  ),
                                ),
                              Text(
                                'R\$ ${product.price.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => _addToCart(product),
                          style: FilledButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          icon: const Icon(Icons.add_shopping_cart, size: 15),
                          label: const Text('Comprar', style: TextStyle(fontSize: 12.5)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
