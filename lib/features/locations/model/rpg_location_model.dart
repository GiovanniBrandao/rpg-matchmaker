// lib/features/locations/model/rpg_location_model.dart
import 'package:flutter/material.dart';

/// Representa um local físico ou espaço parceiro onde mesas de RPG acontecem.
class RpgLocationModel {
  final String id;
  final String name;
  final String type; // ex: 'Taverna & Boardgame Café', 'Loja Parceira', 'Biblioteca / Centro Cultural', 'Hub Online VTT'
  final String city;
  final String address;
  final double distanceKm;
  final double rating;
  final String openingHours;
  final String priceInfo; // ex: 'Entrada gratuita', 'Couvert R$ 15 (consumível)'
  final List<String> amenities; // ex: ['Mesas amplas', 'Dados p/ empréstimo', 'Salas privadas']
  final List<String> popularSystems;
  final bool isPartner;
  final String description;
  final IconData icon;

  const RpgLocationModel({
    required this.id,
    required this.name,
    required this.type,
    required this.city,
    required this.address,
    required this.distanceKm,
    required this.rating,
    required this.openingHours,
    required this.priceInfo,
    required this.amenities,
    required this.popularSystems,
    required this.description,
    this.isPartner = true,
    this.icon = Icons.storefront,
  });

  /// Catálogo curado de locais de encontro para sessões de RPG (presenciais e híbridos/online).
  static const List<RpgLocationModel> catalog = [
    RpgLocationModel(
      id: 'loc-dado- dourado',
      name: 'Taverna do Dado Dourado',
      type: 'Boardgame Café & Pub Geek',
      city: 'Bauru, SP',
      address: 'Av. Getúlio Vargas, 1420 • Jardim América',
      distanceKm: 2.4,
      rating: 4.9,
      openingHours: 'Ter–Dom • 16h às 23h30',
      priceInfo: 'R\$ 15 por pessoa (revertido em consumação)',
      amenities: [
        'Mesas para 8 jogadores',
        'Salas acústicas p/ RPG',
        'Empréstimo de livros e dados',
        'Cardápio temático medieval',
        'Tomadas e Wi-Fi fibra',
      ],
      popularSystems: ['D&D 5e', 'Tormenta20', 'Ordem Paranormal'],
      description:
          'Espaço climatizado com 6 mesas dedicadas a RPG de mesa, iluminação ajustável para clima de aventura e biblioteca com mais de 40 livros básicos disponíveis.',
      isPartner: true,
      icon: Icons.sports_bar,
    ),
    RpgLocationModel(
      id: 'loc-forja-arcana',
      name: 'Forja Arcana Hobby Store',
      type: 'Loja de RPG & Jogos de Mesa',
      city: 'Bauru, SP',
      address: 'Rua Virgílio Malta, 815 • Centro',
      distanceKm: 3.8,
      rating: 4.8,
      openingHours: 'Seg–Sáb • 10h às 21h',
      priceInfo: 'Mesas gratuitas aos sábados',
      amenities: [
        'Grids riscáveis e miniaturas',
        'Encontro de Mestres quinzenal',
        'Mesas iniciantes (One-Shots)',
        'Desconto de 10% p/ usuários do app',
      ],
      popularSystems: ['D&D 5e', 'Pathfinder 2e', 'Call of Cthulhu'],
      description:
          'Loja parceira oficial com espaço nos fundos para 5 mesas simultâneas, empréstimo gratuito de grids táticos, marcadores de condição e miniaturas.',
      isPartner: true,
      icon: Icons.castle,
    ),
    RpgLocationModel(
      id: 'loc-biblioteca-municipal',
      name: 'Centro Cultural & Biblioteca Geek',
      type: 'Espaço Público / Comunitário',
      city: 'Piracicaba, SP',
      address: 'Praça José Bonifácio, 210 • Centro',
      distanceKm: 8.5,
      rating: 4.7,
      openingHours: 'Sáb e Dom • 09h às 18h',
      priceInfo: '100% Gratuito (reserva prévia)',
      amenities: [
        'Ambiente silencioso',
        'Acessibilidade completa',
        'Clube de RPG de Fim de Semana',
        'Ideal para iniciantes',
      ],
      popularSystems: ['Tormenta20', 'D&D 5e', 'Vampiro: A Máscara'],
      description:
          'Salas comunitárias reservadas todo fim de semana para grupos de RPG e oficinas de criação de personagens para novos jogadores.',
      isPartner: false,
      icon: Icons.local_library,
    ),
    RpgLocationModel(
      id: 'loc-santuario-nocturno',
      name: 'Santuário Nocturno Lounge',
      type: 'Café Temático & Sala Imersiva',
      city: 'Campinas, SP',
      address: 'Rua dos Alecrins, 540 • Cambuí',
      distanceKm: 11.2,
      rating: 4.9,
      openingHours: 'Qua–Dom • 18h às 01h',
      priceInfo: 'Reserva de sala R\$ 60 (até 6 pessoas)',
      amenities: [
        'Som ambiente Bluetooth por mesa',
        'TV 50" integrada na mesa p/ mapas digitais',
        'Decoração gótica/investigativa',
      ],
      popularSystems: ['Call of Cthulhu', 'Vampiro: A Máscara', 'Ordem Paranormal'],
      description:
          'Salas reservadas com iluminação baixa, trilha sonora controlada pelo Mestre e tela embutida na mesa para exibir mapas e pistas.',
      isPartner: true,
      icon: Icons.nightlight_round,
    ),
    RpgLocationModel(
      id: 'loc-guilda-vtt',
      name: 'Guilda VTT Brasil (Servidor Oficial)',
      type: 'Hub Online • Discord + Foundry/Roll20',
      city: 'Online • Brasil',
      address: 'Salas de Voz com Bot de Dados & Música',
      distanceKm: 0.0,
      rating: 4.9,
      openingHours: '24 horas • Todos os dias',
      priceInfo: 'Gratuito',
      amenities: [
        'Canais de voz privados por mesa',
        'Bots de rolagem e trilha sonora',
        'Mapas prontos no Roll20 / Foundry',
        'Moderadores de plantão',
      ],
      popularSystems: ['D&D 5e', 'Tormenta20', 'Ordem Paranormal', 'Pathfinder 2e'],
      description:
          'Para grupos à distância: crie uma sala instantânea com canais de áudio dedicados, integração com fichas digitais e suporte a mapas interativos.',
      isPartner: true,
      icon: Icons.headset_mic,
    ),
  ];
}
