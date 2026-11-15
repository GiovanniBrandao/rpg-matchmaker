import 'package:flutter/material.dart';
import '../model/campaign_search_model.dart';
import '../model/character_search_model.dart';
import '../service/table_search_service.dart';

enum SearchMode { tables, characters }

class TableSearchViewModel extends ChangeNotifier {
  final TableSearchService _service = TableSearchService();

  SearchMode _mode = SearchMode.tables;
  bool _isLoading = false;
  String _searchQuery = '';

  List<CampaignSearchModel> _allCampaigns = [];
  List<CampaignSearchModel> _filteredCampaigns = [];

  List<CharacterSearchModel> _allCharacters = [];
  List<CharacterSearchModel> _filteredCharacters = [];

  SearchMode get mode => _mode;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<CampaignSearchModel> get campaigns => _filteredCampaigns;
  List<CharacterSearchModel> get characters => _filteredCharacters;

  /// Define se a busca será de Mesas ou de Personagens
  void setSearchMode(SearchMode newMode) {
    if (_mode == newMode && (_allCampaigns.isNotEmpty || _allCharacters.isNotEmpty)) return;
    _mode = newMode;
    loadData();
  }

  /// Busca os dados do Firestore chamando a camada de Service
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_mode == SearchMode.tables) {
        _allCampaigns = await _service.fetchAllCampaigns();
      } else {
        _allCharacters = await _service.fetchAllCharacters();
      }
      _applyFilter();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza o texto de busca e aplica os filtros dinâmicos
  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    final q = _searchQuery.toLowerCase().trim();

    if (_mode == SearchMode.tables) {
      if (q.isEmpty) {
        _filteredCampaigns = List.from(_allCampaigns);
      } else {
        _filteredCampaigns = _allCampaigns.where((item) {
          return item.campaign.name.toLowerCase().contains(q) ||
              item.campaign.system.toLowerCase().contains(q) ||
              item.campaign.description.toLowerCase().contains(q) ||
              item.masterName.toLowerCase().contains(q);
        }).toList();
      }
    } else {
      if (q.isEmpty) {
        _filteredCharacters = List.from(_allCharacters);
      } else {
        _filteredCharacters = _allCharacters.where((item) {
          final charNameMatch = item.character.name.toLowerCase().contains(q);
          final classMatch = item.character.characterClass.toLowerCase().contains(q);
          final bioMatch = item.character.bio.toLowerCase().contains(q);
          final playerMatch = item.playerName.toLowerCase().contains(q);

          return charNameMatch || classMatch || bioMatch || playerMatch;
        }).toList();
      }
    }
  }
}