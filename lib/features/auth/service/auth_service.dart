// lib/features/auth/service/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  /// Criar Novo Cadastro no Auth e Perfil com Preferências Iniciais no Firestore
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role, // 'player' ou 'master'
    required List<String> favoriteSystems,
    required String proficiency,
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
      // Caso o usuário recuse o GPS no cadastro
    }

    // 3. Registra documento do perfil com dados e preferências iniciais
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': role,
        'proficiency': proficiency,
        'systems': favoriteSystems,
        'photoUrl': '',
        'location': position != null
            ? GeoPoint(position.latitude, position.longitude)
            : null,
        'createdAt': FieldValue.serverTimestamp(),
        'lastOnline': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Continua mesmo que as regras do Firestore restrinjam escrita inicial
    }

    return credential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}