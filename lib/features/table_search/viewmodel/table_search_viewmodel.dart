// lib/features/table_search/viewmodel/table_search_viewmodel.dart
import 'package:flutter/material.dart';
import '../../locations/model/rpg_location_model.dart';
import '../../profile/model/character_model.dart';
import '../../profile/model/master_model.dart';
import '../../profile/model/user_profile_model.dart';
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

  static const List<CampaignSearchModel> _demoCampaigns = [
    CampaignSearchModel(
      campaign: MasterModel(
        id: 'demo-c1',
        masterId: 'm1',
        masterName: 'Mestre Lucas',
        name: 'Taverna do Dragão: Ruínas de Valdris',
        system: 'D&D 5e',
        description:
            'Campanha presencial aos sábados na Taverna do Dado Dourado. Vagas para 2 jogadores de nível 3.',
        isOnline: false,
      ),
      masterId: 'm1',
      masterName: 'Mestre Lucas',
    ),
    CampaignSearchModel(
      campaign: MasterModel(
        id: 'demo-c2',
        masterId: 'm2',
        masterName: 'Helena (Guardia)',
        name: 'Sombras sobre Arkham',
        system: 'Call of Cthulhu',
        description:
            'Investigação sobrenatural nos anos 1920. Encontros às sextas no Santuário Nocturno Lounge.',
        isOnline: false,
      ),
      masterId: 'm2',
      masterName: 'Helena (Guardiã)',
    ),
    CampaignSearchModel(
      campaign: MasterModel(
        id: 'demo-c3',
        masterId: 'm3',
        masterName: 'Rafael VTT',
        name: 'A Coroa Partida de Arton',
        system: 'Tormenta20',
        description:
            'Mesa híbrida (Forja Arcana Hobby Store + Guilda VTT). Ideal para iniciantes e veteranos.',
        isOnline: true,
      ),
      masterId: 'm3',
      masterName: 'Rafael VTT',
    ),
  ];

  static const List<CharacterSearchModel> _demoCharacters = [
    CharacterSearchModel(
      character: CharacterModel(
        id: 'demo-ch1',
        playerId: 'p1',
        playerName: 'Mariana',
        name: 'Lyra Folha-de-Prata',
        characterClass: 'Barda (Colégio do Conhecimento)',
        system: 'D&D 5e',
        bio: 'Especialista em diplomacia, enigmas antigos e suporte mágico ao grupo.',
      ),
      playerId: 'p1',
      playerName: 'Mariana',
      proficiency: ProficiencyLevel.experienced,
    ),
    CharacterSearchModel(
      character: CharacterModel(
        id: 'demo-ch2',
        playerId: 'p2',
        playerName: 'Gabriel',
        name: 'Kaelen Vance',
        characterClass: 'Ocultista Investigador',
        system: 'Ordem Paranormal',
        bio: 'Detetive particular obcecado por rituais e casos arquivados.',
      ),
      playerId: 'p2',
      playerName: 'Gabriel',
      proficiency: ProficiencyLevel.intermed,
    ),
    CharacterSearchModel(
      character: CharacterModel(
        id: 'demo-ch3',
        playerId: 'p3',
        playerName: 'Pedro',
        name: 'Aelar de Wynlla',
        characterClass: 'Arcanista',
        system: 'Tormenta20',
        bio: 'Mago estudioso em busca de artefatos perdidos da Tormenta.',
      ),
      playerId: 'p3',
      playerName: 'Pedro',
      proficiency: ProficiencyLevel.beginner,
    ),
  ];

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
        final remote = await _service.fetchAllCampaigns();
        _allCampaigns = remote.isNotEmpty ? remote : List.of(_demoCampaigns);
      } else if (_mode == SearchMode.characters) {
        final remote = await _service.fetchAllCharacters();
        _allCharacters = remote.isNotEmpty ? remote : List.of(_demoCharacters);
      }
      _applyFilter();
    } catch (_) {
      if (_mode == SearchMode.tables) {
        _allCampaigns = List.of(_demoCampaigns);
      } else {
        _allCharacters = List.of(_demoCharacters);
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
