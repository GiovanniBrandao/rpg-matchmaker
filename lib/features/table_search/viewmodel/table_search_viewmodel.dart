// lib/features/table_search/viewmodel/table_search_viewmodel.dart
import 'package:flutter/material.dart';
import '../../locations/model/rpg_location_model.dart';
import '../model/campaign_search_model.dart';
import '../model/character_search_model.dart';
import '../service/table_search_service.dart';

enum SearchMode { tables, characters, locations }

class TableSearchViewModel extends ChangeNotifier {
  final TableSearchService _service = TableSearchService();

  SearchMode _mode = SearchMode.tables;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<CampaignSearchModel> _allCampaigns = [];
  List<CampaignSearchModel> _filteredCampaigns = [];

  List<CharacterSearchModel> _allCharacters = [];
  List<CharacterSearchModel> _filteredCharacters = [];

  List<RpgLocationModel> _filteredLocations = List.of(RpgLocationModel.catalog);

  SearchMode get mode => _mode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CampaignSearchModel> get campaigns => _filteredCampaigns;
  List<CharacterSearchModel> get characters => _filteredCharacters;
  List<RpgLocationModel> get locations => _filteredLocations;

  void setSearchMode(SearchMode newMode) {
    if (_mode == newMode &&
        (_allCampaigns.isNotEmpty ||
            _allCharacters.isNotEmpty ||
            _mode == SearchMode.locations)) {
      return;
    }
    _mode = newMode;
    _searchQuery = '';
    loadData();
  }

  Future<void> loadData() async {
    if (_mode == SearchMode.locations) {
      _applyFilter();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_mode == SearchMode.tables) {
        _allCampaigns = await _service.fetchAllCampaigns();
      } else if (_mode == SearchMode.characters) {
        _allCharacters = await _service.fetchAllCharacters();
      }
      _applyFilter();
    } catch (e) {
      debugPrint('Erro ao buscar dados em TableSearch: $e');
      if (_mode == SearchMode.tables) {
        _allCampaigns = [];
      } else {
        _allCharacters = [];
      }
      _applyFilter();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
    } else if (_mode == SearchMode.characters) {
      if (q.isEmpty) {
        _filteredCharacters = List.from(_allCharacters);
      } else {
        _filteredCharacters = _allCharacters.where((item) {
          return item.character.name.toLowerCase().contains(q) ||
              item.character.characterClass.toLowerCase().contains(q) ||
              item.character.bio.toLowerCase().contains(q) ||
              item.playerName.toLowerCase().contains(q);
        }).toList();
      }
    } else {
      if (q.isEmpty) {
        _filteredLocations = List.of(RpgLocationModel.catalog);
      } else {
        _filteredLocations = RpgLocationModel.catalog.where((loc) {
          return loc.name.toLowerCase().contains(q) ||
              loc.city.toLowerCase().contains(q) ||
              loc.type.toLowerCase().contains(q) ||
              loc.popularSystems.any((s) => s.toLowerCase().contains(q));
        }).toList();
      }
    }
  }
}