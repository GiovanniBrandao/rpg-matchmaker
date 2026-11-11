// lib/features/swipe/service/swipe_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../model/swipe_model.dart';

class SwipeService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// Solicita permissão e lê a localização atual via GPS
  Future<Position?> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('⚠️ GPS desativado.');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('ℹ️ Permissão de GPS ainda não concedida; usando distância padrão.');
      return null;
    }

    final pos = await Geolocator.getCurrentPosition();
    debugPrint('📍 GPS OK: Lat ${pos.latitude}, Lng ${pos.longitude}');
    return pos;
  }

  /// Busca Campanhas na coleção raiz 'campaigns'
  Future<List<SwipeItemModel>> fetchCampaignCards() async {
    try {
      final snapshot = await _firestore.collection('campaigns').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SwipeItemModel(
          id: doc.id,
          title: data['name'] ?? 'Mesa Sem Nome',
          system: data['system'] ?? 'Geral',
          location: data['isOnline'] == true 
              ? 'Online • Discord/VTT' 
              : 'Presencial • Mestre ${data['masterName'] ?? "N/A"}',
          desc: data['description'] ?? 'Sem descrição informada.',
          imagePath: data['imagePath'] ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('Erro ao buscar campanhas na coleção campaigns: $e');
      return [];
    }
  }

  /// Busca Personagens na coleção raiz 'characters'
  Future<List<SwipeItemModel>> fetchCharacterCards() async {
    try {
      final snapshot = await _firestore.collection('characters').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SwipeItemModel(
          id: doc.id,
          title: data['name'] ?? 'Personagem',
          system: data['characterClass'] ?? data['system'] ?? 'Aventureiro',
          location: 'Jogador: ${data['playerName'] ?? "N/A"}',
          desc: data['bio'] ?? 'Sem biografia informada.',
          imagePath: data['imagePath'] ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('Erro ao buscar personagens na coleção characters: $e');
      return [];
    }
  }
}