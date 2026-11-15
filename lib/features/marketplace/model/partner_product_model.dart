// lib/features/marketplace/model/partner_product_model.dart
import 'package:flutter/material.dart';

enum ProductCategory {
  all('Todos', Icons.apps),
  books('Livros & Sistemas', Icons.menu_book),
  dice('Dados & Acessórios', Icons.casino),
  minis('Miniaturas & Mapas', Icons.extension),
  digital('Digital & VTT', Icons.devices);

  final String label;
  final IconData icon;
  const ProductCategory(this.label, this.icon);
}

/// Produto de RPG vendido por lojas/criadores parceiros via comissão de afiliado.
class PartnerProductModel {
  final String id;
  final String title;
  final String partnerName;
  final String partnerCity;
  final ProductCategory category;
  final String system;
  final double price;
  final double? originalPrice;
  final int commissionPercent; // % de comissão repassada ao app / mestre afiliado
  final String affiliateCoupon;
  final double rating;
  final int salesCount;
  final String description;
  final List<String> highlights;
  final IconData icon;
  final Color accentColor;

  const PartnerProductModel({
    required this.id,
    required this.title,
    required this.partnerName,
    required this.partnerCity,
    required this.category,
    required this.system,
    required this.price,
    this.originalPrice,
    required this.commissionPercent,
    required this.affiliateCoupon,
    required this.rating,
    required this.salesCount,
    required this.description,
    required this.highlights,
    required this.icon,
    required this.accentColor,
  });

  /// Valor em R$ da comissão gerada por venda.
  double get commissionValue => price * (commissionPercent / 100.0);

  static const List<PartnerProductModel> catalog = [
    PartnerProductModel(
      id: 'prod-tormenta20-jda',
      title: 'Tormenta20 — Jogo do Ano (Capa Dura + PDF)',
      partnerName: 'Forja Arcana Hobby Store',
      partnerCity: 'Parceiro Oficial • Envio Imediato',
      category: ProductCategory.books,
      system: 'Tormenta20',
      price: 189.90,
      originalPrice: 229.90,
      commissionPercent: 12,
      affiliateCoupon: 'MATCHT20',
      rating: 4.9,
      salesCount: 342,
      description:
          'Livro básico completo revisado da edição Jogo do Ano de Tormenta20. Inclui código para download da versão digital em PDF.',
      highlights: [
        '400 páginas coloridas em capa dura',
        'Inclui PDF oficial liberado na hora',
        'Frete grátis para mesas cadastradas no app',
      ],
      icon: Icons.auto_stories,
      accentColor: Color(0xFFB91C1C),
    ),
    PartnerProductModel(
      id: 'prod-dados-obsidiana',
      title: 'Kit 7 Dados Poliédricos Metal & Obsidiana Dourada',
      partnerName: 'Taverna do Dado Dourado',
      partnerCity: 'Bauru, SP • Retirada ou Correios',
      category: ProductCategory.dice,
      system: 'Todos os Sistemas',
      price: 119.00,
      originalPrice: 149.00,
      commissionPercent: 18,
      affiliateCoupon: 'DADOOURO10',
      rating: 4.9,
      salesCount: 518,
      description:
          'Conjunto balanceado de 7 dados (D4, D6, D8, 2x D10/D100, D12 e D20) em liga metálica com números em alto contraste dourado e estojo de couro sintético.',
      highlights: [
        'Acompanha bolsa/bandeja de couro dobrável',
        'Peso tátil premium (185g o conjunto)',
        'Garantia vitalícia contra defeitos de balanceamento',
      ],
      icon: Icons.casino,
      accentColor: Color(0xFFD97706),
    ),
    PartnerProductModel(
      id: 'prod-grid-tatico',
      title: 'Grid Tático Riscável Dupla Face (Masmorra & Gramado) + 4 Canetas',
      partnerName: 'Masmorra Criativa Estúdio',
      partnerCity: 'Campinas, SP • Entrega Expressa',
      category: ProductCategory.minis,
      system: 'D&D 5e',
      price: 84.50,
      originalPrice: 109.00,
      commissionPercent: 15,
      affiliateCoupon: 'GRIDMATCH',
      rating: 4.8,
      salesCount: 276,
      description:
          'Tapete tático laminado de 90x60cm com quadrados de 2,5cm (1 polegada) de um lado e hexágonos no verso. Apaga a seco sem manchar.',
      highlights: [
        'Acompanha 4 marcadores apagáveis e apagador',
        'Resistente a líquidos (café e refrigerante)',
        'Tubo rígido com alça para transporte',
      ],
      icon: Icons.grid_on,
      accentColor: Color(0xFF15803D),
    ),
    PartnerProductModel(
      id: 'prod-pack-minis-herois',
      title: 'Pack 12 Miniaturas Resina 3D (Heróis + Monstros Clássicos)',
      partnerName: 'Bigorna 3D Miniaturas',
      partnerCity: 'São Paulo, SP • Parceiro Verificado',
      category: ProductCategory.minis,
      system: 'D&D 5e',
      price: 139.90,
      originalPrice: 175.00,
      commissionPercent: 20,
      affiliateCoupon: 'MINI20',
      rating: 4.9,
      salesCount: 194,
      description:
          'Miniaturas impressas em resina 8K de alta definição: 6 classes de aventureiros e 6 criaturas (Goblin, Esqueleto, Mímico, Ogro, Cultista e Dragão Jovem).',
      highlights: [
        'Escala padrão 32mm com base texturizada',
        'Já curadas e com primer cinza aplicado',
        'Prontas para usar na mesa ou pintar',
      ],
      icon: Icons.shield,
      accentColor: Color(0xFF6D28D9),
    ),
    PartnerProductModel(
      id: 'prod-escudo-mestre',
      title: 'Escudo do Mestre em Madeira Cortada a Laser + Torre de Dados',
      partnerName: 'Oficina do Druida',
      partnerCity: 'Curitiba, PR • Artesanal',
      category: ProductCategory.dice,
      system: 'Todos os Sistemas',
      price: 164.00,
      originalPrice: 199.00,
      commissionPercent: 15,
      affiliateCoupon: 'MESTRE15',
      rating: 5.0,
      salesCount: 129,
      description:
          'Escudo dobrável de 4 abas com suporte magnético para folhas de referência A4 (qualquer sistema) e torre de dados acoplável.',
      highlights: [
        'Ímãs de neodímio inclusos para prender tabelas',
        'Rastreador de iniciativa no topo do escudo',
        'Torre de dados desmontável integrada',
      ],
      icon: Icons.security,
      accentColor: Color(0xFF92400E),
    ),
    PartnerProductModel(
      id: 'prod-vtt-bundle',
      title: 'Mega Pack 80 Mapas Animados + 300 Tokens p/ Roll20 e Foundry VTT',
      partnerName: 'Cartógrafo Astral Digital',
      partnerCity: 'Download Digital Instantâneo',
      category: ProductCategory.digital,
      system: 'Ordem Paranormal',
      price: 49.90,
      originalPrice: 79.90,
      commissionPercent: 25,
      affiliateCoupon: 'VTT25',
      rating: 4.8,
      salesCount: 610,
      description:
          'Pacote digital completo com mapas em 4K (fantasia medieval, terror anos 1920 e investigação urbana moderna), iluminação dinâmica pré-configurada e trilhas sonoras.',
      highlights: [
        'Compatível com Foundry VTT, Roll20 e Owlbear Rodeo',
        'Versões Dia, Noite e Chuva de cada mapa',
        'Acesso vitalício às atualizações mensais',
      ],
      icon: Icons.map,
      accentColor: Color(0xFF0369A1),
    ),
  ];
}
