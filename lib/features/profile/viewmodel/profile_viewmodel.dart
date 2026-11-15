import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/character_model.dart';
import '../model/user_profile_model.dart';
import '../model/master_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  );

  bool get isLoading => _isLoading;
  UserProfileModel get profile => _profile;

  final List<String> availableSystems = const [
    'D&D 5e', 'Tormenta20', 'Call of Cthulhu', 
    'Pathfinder 2e', 'Vampiro: A Máscara', 'Ordem Paranormal'
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
    final user = _auth.currentUser;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _userSub = _firestore.collection('users').doc(user.uid).snapshots().listen(
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
          await _firestore.collection('users').doc(user.uid).set({
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

    _campaignsSub = _firestore
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

    _charactersSub = _firestore
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
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update(data);
    }
  }

  void toggleIsGameMaster(bool value) {
    _profile = _profile.copyWith(isGameMaster: value);
    notifyListeners();
    _updateField({'role': value ? 'master' : 'player'});
  }

  Future<void> addCampaign(MasterModel campaign) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final campaignData = campaign.copyWith(
      masterId: user.uid,
      masterName: _profile.userName.isNotEmpty ? _profile.userName : 'Mestre',
    ).toMap();

    await _firestore.collection('campaigns').add(campaignData);
  }

  Future<void> updateCampaign(MasterModel updatedCampaign) async {
    await _firestore
        .collection('campaigns')
        .doc(updatedCampaign.id)
        .update(updatedCampaign.toMap());
  }

  Future<void> addCharacter(CharacterModel character) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final charData = character.copyWith(
      playerId: user.uid,
      playerName: _profile.userName.isNotEmpty ? _profile.userName : 'Jogador',
    ).toMap();

    await _firestore.collection('characters').add(charData);
  }

  // ================= DELEÇÃO DE CAMPANHAS E PERSONAGENS =================

  Future<void> deleteCampaign(String campaignId) async {
    if (campaignId.isEmpty) return;
    try {
      await _firestore.collection('campaigns').doc(campaignId).delete();
    } catch (e) {
      debugPrint('Erro ao deletar campanha: $e');
    }
  }

  Future<void> deleteCharacter(String characterId) async {
    if (characterId.isEmpty) return;
    try {
      await _firestore.collection('characters').doc(characterId).delete();
    } catch (e) {
      debugPrint('Erro ao deletar personagem: $e');
    }
  }

  Future<void> updateCharacter(CharacterModel updatedChar) async {
    await _firestore
        .collection('characters')
        .doc(updatedChar.id)
        .update(updatedChar.toMap());
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