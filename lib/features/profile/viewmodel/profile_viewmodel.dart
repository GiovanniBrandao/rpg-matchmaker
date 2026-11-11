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

  final List<String> availableSystems = const [
    'D&D 5e',
    'Tormenta20',
    'Call of Cthulhu',
    'Pathfinder 2e',
    'Vampiro: A Máscara',
    'Ordem Paranormal',
  ];

  UserProfileModel _profile = const UserProfileModel(
    id: 'demo-user',
    userName: 'Aventureiro da Taverna',
    email: 'aventureiro@rpg.com',
    favoriteSystems: ['D&D 5e', 'Tormenta20'],
    proficiency: ProficiencyLevel.intermed,
    characters: [
      CharacterModel(
        id: 'char-1',
        name: 'Alden Escudo-de-Ferro',
        characterClass: 'Paladino Nv. 3',
        system: 'D&D 5e',
        bio: 'Guardião juramentado que busca restaurar a antiga ordem de Valdris.',
      ),
    ],
    campaigns: [
      MasterModel(
        id: 'camp-1',
        name: 'Crônicas da Taverna Dourada',
        system: 'D&D 5e',
        description: 'Aventura semanal presencial e híbrida para heróis de nível 1 a 5.',
        isOnline: false,
      ),
    ],
  );

  bool _isLoading = true;
  StreamSubscription? _userSub;
  StreamSubscription? _campaignsSub;
  StreamSubscription? _charactersSub;

  UserProfileModel get profile => _profile;
  bool get isLoading => _isLoading;

  ProfileViewModel() {
    _listenToUserData();
  }

  void _listenToUserData() {
    final user = _auth?.currentUser;
    final fs = _firestore;
    if (user == null || fs == null) {
      _isLoading = false;
      return;
    }

    _profile = _profile.copyWith(
      id: user.uid,
      email: user.email ?? _profile.email,
    );

    // 1. Escuta o perfil na coleção 'users'
    _userSub = fs.collection('users').doc(user.uid).snapshots().listen(
      (snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          _profile = UserProfileModel.fromMap(
            user.uid,
            snapshot.data()!,
            campaigns: _profile.campaigns,
            characters: _profile.characters,
          );
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );

    // 2. Escuta as campanhas na coleção raiz 'campaigns'
    _campaignsSub = fs
        .collection('campaigns')
        .where('masterId', isEqualTo: user.uid)
        .snapshots()
        .listen(
      (snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final campaigns = snapshot.docs
              .map((doc) => MasterModel.fromMap(doc.data(), docId: doc.id))
              .toList();
          _profile = _profile.copyWith(campaigns: campaigns);
          notifyListeners();
        }
      },
      onError: (_) {},
    );

    // 3. Escuta os personagens na coleção raiz 'characters'
    _charactersSub = fs
        .collection('characters')
        .where('playerId', isEqualTo: user.uid)
        .snapshots()
        .listen(
      (snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final characters = snapshot.docs
              .map((doc) => CharacterModel.fromMap(doc.data(), docId: doc.id))
              .toList();
          _profile = _profile.copyWith(characters: characters);
          notifyListeners();
        }
      },
      onError: (_) {},
    );
  }

  Future<void> _updateField(Map<String, dynamic> data) async {
    final user = _auth?.currentUser;
    final fs = _firestore;
    if (user != null && fs != null) {
      try {
        await fs.collection('users').doc(user.uid).update(data);
      } catch (_) {}
    }
  }

  void toggleIsGameMaster(bool value) {
    _profile = _profile.copyWith(isGameMaster: value);
    notifyListeners();
    _updateField({'role': value ? 'master' : 'player'});
  }

  Future<void> addCampaign(MasterModel campaign) async {
    final newCamp = campaign.copyWith(
      id: campaign.id.isEmpty
          ? 'camp-${DateTime.now().millisecondsSinceEpoch}'
          : campaign.id,
      masterId: _auth?.currentUser?.uid ?? 'demo-user',
      masterName: _profile.userName.isNotEmpty ? _profile.userName : 'Mestre',
    );
    _profile = _profile.copyWith(campaigns: [..._profile.campaigns, newCamp]);
    notifyListeners();

    final user = _auth?.currentUser;
    final fs = _firestore;
    if (user != null && fs != null) {
      try {
        await fs.collection('campaigns').add(newCamp.toMap());
      } catch (_) {}
    }
  }

  Future<void> updateCampaign(MasterModel updatedCampaign) async {
    final updatedList = _profile.campaigns
        .map((c) => c.id == updatedCampaign.id ? updatedCampaign : c)
        .toList();
    _profile = _profile.copyWith(campaigns: updatedList);
    notifyListeners();

    final fs = _firestore;
    if (fs != null && _auth?.currentUser != null) {
      try {
        await fs
            .collection('campaigns')
            .doc(updatedCampaign.id)
            .update(updatedCampaign.toMap());
      } catch (_) {}
    }
  }

  Future<void> addCharacter(CharacterModel character) async {
    final newChar = character.copyWith(
      id: character.id.isEmpty
          ? 'char-${DateTime.now().millisecondsSinceEpoch}'
          : character.id,
      playerId: _auth?.currentUser?.uid ?? 'demo-user',
      playerName: _profile.userName.isNotEmpty ? _profile.userName : 'Jogador',
    );
    _profile = _profile.copyWith(characters: [..._profile.characters, newChar]);
    notifyListeners();

    final user = _auth?.currentUser;
    final fs = _firestore;
    if (user != null && fs != null) {
      try {
        await fs.collection('characters').add(newChar.toMap());
      } catch (_) {}
    }
  }

  Future<void> updateCharacter(CharacterModel updatedChar) async {
    final updatedList = _profile.characters
        .map((c) => c.id == updatedChar.id ? updatedChar : c)
        .toList();
    _profile = _profile.copyWith(characters: updatedList);
    notifyListeners();

    final fs = _firestore;
    if (fs != null && _auth?.currentUser != null) {
      try {
        await fs
            .collection('characters')
            .doc(updatedChar.id)
            .update(updatedChar.toMap());
      } catch (_) {}
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
