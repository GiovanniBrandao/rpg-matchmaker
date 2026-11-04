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

  final List<String> availableSystems = const [
    'D&D 5e', 'Tormenta20', 'Call of Cthulhu', 
    'Pathfinder 2e', 'Vampiro: A Máscara', 'Ordem Paranormal'
  ];

  UserProfileModel _profile = const UserProfileModel(
    id: '',
    userName: '',
    email: '',
    favoriteSystems: [],
    proficiency: ProficiencyLevel.intermed,
  );

  bool _isLoading = true;
  StreamSubscription? _subscription;

  UserProfileModel get profile => _profile;
  bool get isLoading => _isLoading;

  ProfileViewModel() {
    _listenToUserData();
  }

  void _listenToUserData() {
    final user = _auth.currentUser;
    if (user == null) return;

    _subscription = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        _profile = UserProfileModel.fromMap(user.uid, snapshot.data()!);
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _updateField(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update(data);
    }
  }

  void toggleIsGameMaster(bool value) {
    _updateField({'role': value ? 'master' : 'player'});
  }

  void addCampaign(MasterModel campaign) {
    final updatedList = [..._profile.campaigns, campaign];
    _updateField({'campaigns': updatedList.map((c) => c.toMap()).toList()});
  }

  void updateCampaign(MasterModel updatedCampaign) {
    final updatedList = _profile.campaigns.map((c) {
      return c.id == updatedCampaign.id ? updatedCampaign : c;
    }).toList();
    _updateField({'campaigns': updatedList.map((c) => c.toMap()).toList()});
  }

  void addCharacter(CharacterModel character) {
    final updatedList = [..._profile.characters, character];
    _updateField({'characters': updatedList.map((c) => c.toMap()).toList()});
  }

  void updateCharacter(CharacterModel updatedChar) {
    final updatedList = _profile.characters.map((c) {
      return c.id == updatedChar.id ? updatedChar : c;
    }).toList();
    _updateField({'characters': updatedList.map((c) => c.toMap()).toList()});
  }

  void toggleSystem(String system) {
    final current = List<String>.from(_profile.favoriteSystems);
    current.contains(system) ? current.remove(system) : current.add(system);
    _updateField({'systems': current});
  }

  void setProficiency(ProficiencyLevel? level) {
    if (level != null) {
      _updateField({'proficiency': level.name});
    }
  }

  void saveUserData({required String name, required String email}) {
    _updateField({'name': name, 'email': email});
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}