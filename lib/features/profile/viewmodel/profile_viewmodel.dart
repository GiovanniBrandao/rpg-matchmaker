// lib/features/profile/viewmodel/profile_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/character_model.dart';
import '../model/user_profile_model.dart';
import '../model/master_model.dart';

class ProfileViewModel extends ChangeNotifier {
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  StreamSubscription? _userSub;
  StreamSubscription? _campaignsSub;
  StreamSubscription? _charactersSub;

  bool _isLoading = true;
  UserProfileModel _profile = const UserProfileModel(
    id: '',
    userName: '',
    email: '',
    favoriteSystems: [],
    proficiency: ProficiencyLevel.intermed,
    characters: [],
    campaigns: [],
  );

  bool get isLoading => _isLoading;
  UserProfileModel get profile => _profile;

  final List<String> availableSystems = const [
    'D&D 5e',
    'Tormenta20',
    'Call of Cthulhu',
    'Pathfinder 2e',
    'Vampiro: A Máscara',
    'Ordem Paranormal',
  ];

  ProfileViewModel() {
    _listenToUserData();
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    await _userSub?.cancel();
    await _campaignsSub?.cancel();
    await _charactersSub?.cancel();

    _listenToUserData();
  }

  void _listenToUserData() {
    final user = _auth?.currentUser;
    final fs = _firestore;
    if (user == null || fs == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    // 1. Escuta os dados cadastrais do usuário
    _userSub = fs.collection('users').doc(user.uid).snapshots().listen(
      (snapshot) async {
        if (snapshot.exists && snapshot.data() != null) {
          try {
            _profile = UserProfileModel.fromMap(
              user.uid,
              snapshot.data()!,
              campaigns: _profile.campaigns,
              characters: _profile.characters,
            );
          } catch (e) {
            debugPrint('Erro ao converter UserProfileModel: $e');
          }
          _isLoading = false;
          notifyListeners();
        } else {
          await fs.collection('users').doc(user.uid).set({
            'name': user.displayName ?? 'Novo Usuário',
            'email': user.email ?? '',
            'role': 'player',
            'proficiency': 'intermed',
            'systems': <String>[],
          });
          _isLoading = false;
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint('Erro na stream de users: $error');
        _isLoading = false;
        notifyListeners();
      },
    );

    // 2. Escuta as campanhas do mestre na coleção raiz 'campaigns'
    _campaignsSub = fs
        .collection('campaigns')
        .where('masterId', isEqualTo: user.uid)
        .snapshots()
        .listen(
      (snapshot) {
        final campaigns = snapshot.docs
            .map((doc) => MasterModel.fromMap(doc.data(), docId: doc.id))
            .toList();
        _profile = _profile.copyWith(campaigns: campaigns);
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Erro na stream de campaigns: $error');
      },
    );

    // 3. Escuta os personagens do jogador na coleção raiz 'characters'
    _charactersSub = fs
        .collection('characters')
        .where('playerId', isEqualTo: user.uid)
        .snapshots()
        .listen(
      (snapshot) {
        final characters = snapshot.docs
            .map((doc) => CharacterModel.fromMap(doc.data(), docId: doc.id))
            .toList();
        _profile = _profile.copyWith(characters: characters);
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Erro na stream de characters: $error');
      },
    );
  }

  Future<void> _updateField(Map<String, dynamic> data) async {
    final user = _auth?.currentUser;
    final fs = _firestore;
    if (user != null && fs != null) {
      try {
        await fs.collection('users').doc(user.uid).update(data);
      } catch (e) {
        debugPrint('Erro ao atualizar perfil: $e');
      }
    }
  }

  void toggleIsGameMaster(bool value) {
    _profile = _profile.copyWith(isGameMaster: value);
    notifyListeners();
    _updateField({'role': value ? 'master' : 'player'});
  }

  Future<void> addCampaign(MasterModel campaign) async {
    final user = _auth?.currentUser;
    final fs = _firestore;
    if (user == null || fs == null) return;

    final campaignData = campaign.copyWith(
      masterId: user.uid,
      masterName: _profile.userName.isNotEmpty ? _profile.userName : 'Mestre',
    ).toMap();

    await fs.collection('campaigns').add(campaignData);
  }

  Future<void> updateCampaign(MasterModel updatedCampaign) async {
    final fs = _firestore;
    if (fs == null || updatedCampaign.id.isEmpty) return;

    await fs
        .collection('campaigns')
        .doc(updatedCampaign.id)
        .update(updatedCampaign.toMap());
  }

  Future<void> deleteCampaign(String campaignId) async {
    final fs = _firestore;
    if (fs == null || campaignId.isEmpty) return;

    try {
      await fs.collection('campaigns').doc(campaignId).delete();
    } catch (e) {
      debugPrint('Erro ao deletar campanha: $e');
    }
  }

  Future<void> addCharacter(CharacterModel character) async {
    final user = _auth?.currentUser;
    final fs = _firestore;
    if (user == null || fs == null) return;

    final charData = character.copyWith(
      playerId: user.uid,
      playerName: _profile.userName.isNotEmpty ? _profile.userName : 'Jogador',
    ).toMap();

    await fs.collection('characters').add(charData);
  }

  Future<void> updateCharacter(CharacterModel updatedChar) async {
    final fs = _firestore;
    if (fs == null || updatedChar.id.isEmpty) return;

    await fs
        .collection('characters')
        .doc(updatedChar.id)
        .update(updatedChar.toMap());
  }

  Future<void> deleteCharacter(String characterId) async {
    final fs = _firestore;
    if (fs == null || characterId.isEmpty) return;

    try {
      await fs.collection('characters').doc(characterId).delete();
    } catch (e) {
      debugPrint('Erro ao deletar personagem: $e');
    }
  }

  void toggleSystem(String system) {
    final current = List<String>.from(_profile.favoriteSystems);
    current.contains(system) ? current.remove(system) : current.add(system);
    _profile = _profile.copyWith(favoriteSystems: current);
    notifyListeners();
    _updateField({'systems': current});
  }

  void setProficiency(ProficiencyLevel? level) {
    if (level != null) {
      _profile = _profile.copyWith(proficiency: level);
      notifyListeners();
      _updateField({'proficiency': level.name});
    }
  }

  void saveUserData({required String name, required String email}) {
    _profile = _profile.copyWith(userName: name, email: email);
    notifyListeners();
    _updateField({'name': name, 'email': email});
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _campaignsSub?.cancel();
    _charactersSub?.cancel();
    super.dispose();
  }
}