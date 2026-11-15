// lib/features/swipe/viewmodel/swipe_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../model/swipe_model.dart';
import '../service/swipe_service.dart';

enum SwipeMode { player, master }

class SwipeViewModel extends ChangeNotifier {
  final SwipeService _service = SwipeService();

  SwipeMode _mode = SwipeMode.player;
  bool _isLoading = false;
  List<SwipeItemModel> _cards = [];
  Position? _currentPosition;

  SwipeMode get mode => _mode;
  bool get isLoading => _isLoading;
  List<SwipeItemModel> get cards => _cards;

  void setMode(SwipeMode newMode) {
    if (_mode == newMode && _cards.isNotEmpty) return;
    _mode = newMode;
    loadCards();
  }

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Solicita localização (se necessário para cálculos de distância)
      _currentPosition = await _service.getUserLocation();

      if (_mode == SwipeMode.player) {
        // Jogador busca Mesas para jogar
        _cards = await _service.fetchCampaignCards();
      } else {
        // Mestre busca Personagens/Jogadores
        _cards = await _service.fetchCharacterCards();
      }
    } catch (e) {
      debugPrint("Erro ao carregar cards: $e");
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