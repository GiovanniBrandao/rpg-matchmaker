// lib/features/auth/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Usuário atualmente autenticado (se houver)
  User? get currentUser => _auth.currentUser;

  /// Stream para escutar mudanças no estado de login em tempo real
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Fazer Login com E-mail e Senha
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  /// Criar Novo Cadastro no Auth e Perfil no Firestore
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role, // 'player' ou 'master'
  }) async {
    // 1. Cria conta de autenticação
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final uid = credential.user!.uid;

    // 2. Obtém localização aproximada (se permissão concedida)
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
    } catch (_) {
      // Caso o usuário recuse o GPS no cadastro, registra sem coordenadas iniciais
    }

    // 3. Registra documento do perfil no Firestore
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name.trim(),
      'email': email.trim(),
      'role': role,
      'systems': <String>['D&D 5e'], // Padrão inicial
      'photoUrl': '',
      'location': position != null
          ? GeoPoint(position.latitude, position.longitude)
          : null,
      'createdAt': FieldValue.serverTimestamp(),
      'lastOnline': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  /// Sair do App
  Future<void> signOut() async {
    await _auth.signOut();
  }
}