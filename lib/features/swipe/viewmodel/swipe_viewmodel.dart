// lib/features/swipe/viewmodel/swipe_viewmodel.dart
import 'package:flutter/material.dart';
import '../model/swipe_model.dart';
import '../service/swipe_service.dart';

enum SwipeMode { player, master }

class SwipeViewModel extends ChangeNotifier {
  final SwipeService _service = SwipeService();

  SwipeMode _mode = SwipeMode.player;
  bool _isLoading = false;
  List<SwipeItemModel> _cards = [];

  SwipeMode get mode => _mode;
  bool get isLoading => _isLoading;
  List<SwipeItemModel> get cards => _cards;

  static const List<SwipeItemModel> _demoCampaignCards = [
    SwipeItemModel(
      id: 'camp-arkham',
      title: 'Sombras sobre Arkham',
      system: 'Call of Cthulhu',
      location: 'Presencial • 3,8 km de você',
      suggestedVenue: 'Santuário Nocturno Lounge (Sala Acústica 2)',
      schedule: 'Sextas-feiras • 20h às 23h30',
      desc:
          'Mesa investigativa de terror nos anos 1920. Procuramos 2 investigadores focados em roleplay e dedução de pistas.',
      imagePath: '',
      distanceKm: 3.8,
    ),
    SwipeItemModel(
      id: 'camp-coroa-rubra',
      title: 'A Coroa Partida de Arton',
      system: 'Tormenta20',
      location: 'Híbrido • Bauru, SP (3,8 km)',
      suggestedVenue: 'Forja Arcana Hobby Store (Mesa 3)',
      schedule: 'Domingos quinzenais • 15h às 20h',
      desc:
          'Campanha heroica do nível 1 ao 10 contra a Tormenta. Aceitamos iniciantes! Livros e dados disponíveis no local.',
      imagePath: '',
      distanceKm: 3.8,
    ),
    SwipeItemModel(
      id: 'camp-taverna-dragao',
      title: 'Taverna do Dragão: Ruínas de Valdris',
      system: 'D&D 5e',
      location: 'Presencial • Bauru, SP (2,4 km)',
      suggestedVenue: 'Taverna do Dado Dourado (Av. Getúlio Vargas, 1420)',
      schedule: 'Sábados • 18h às 22h30',
      desc:
          'Procurando 2 aventureiros de nível 3 para explorar masmorras antigas e intrigas políticas. Primeira rodada de hidromel por conta do Mestre!',
      imagePath: '',
      distanceKm: 2.4,
    ),
  ];

  static const List<SwipeItemModel> _demoCharacterCards = [
    SwipeItemModel(
      id: 'char-kael',
      title: 'Kaelen, Ocultista Investigador',
      system: 'Ordem Paranormal',
      location: 'Disponível Presencial ou Online (4,1 km)',
      suggestedVenue: 'Santuário Nocturno Lounge ou Guilda VTT',
      schedule: 'Sextas e Sábados à noite',
      desc:
          'Jogador experiente que adora criar teorias, anotar todas as pistas da sessão e ajudar novos jogadores com regras.',
      imagePath: '',
      distanceKm: 4.1,
    ),
    SwipeItemModel(
      id: 'char-lyra',
      title: 'Lyra Folha-de-Prata (Barda Nv. 3)',
      system: 'D&D 5e',
      location: 'Presencial • Bauru, SP (2,1 km)',
      suggestedVenue: 'Taverna do Dado Dourado / Forja Arcana',
      schedule: 'Fins de semana (tarde ou noite)',
      desc:
          'Focada em interpretação, diplomacia e suporte ao grupo. Levo trilha sonora personalizada para as sessões!',
      imagePath: '',
      distanceKm: 2.1,
    ),
    SwipeItemModel(
      id: 'char-aelar',
      title: 'Aelar, Arcanista de Wynlla',
      system: 'Tormenta20',
      location: 'Online ou Presencial (3,5 km)',
      suggestedVenue: 'Forja Arcana Hobby Store / Discord',
      schedule: 'Sábados ou Domingos',
      desc:
          'Personagem focado em controle de campo e história rica com gancho pronto para o Mestre integrar na campanha.',
      imagePath: '',
      distanceKm: 3.5,
    ),
  ];

  void setMode(SwipeMode newMode) {
    if (_mode == newMode && _cards.isNotEmpty) return;
    _mode = newMode;
    loadCards();
  }

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.getUserLocation();

      if (_mode == SwipeMode.player) {
        final remote = await _service.fetchCampaignCards();
        _cards = remote.isNotEmpty ? remote : List.of(_demoCampaignCards);
      } else {
        final remote = await _service.fetchCharacterCards();
        _cards = remote.isNotEmpty ? remote : List.of(_demoCharacterCards);
      }
    } catch (e) {
      debugPrint('Usando cards de demonstração no Swipe: $e');
      _cards = _mode == SwipeMode.player
          ? List.of(_demoCampaignCards)
          : List.of(_demoCharacterCards);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void removeTopCard() {
    if (_cards.isNotEmpty) {
      _cards.removeLast();
      notifyListeners();
    }
  }
}
