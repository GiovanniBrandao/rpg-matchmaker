// lib/features/chat/service/chat_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/chat_models.dart';

/// Serviço de chat em tempo real usando Cloud Firestore com fallback local reativo.
///
/// Estrutura no Firestore:
///   chats/{roomId}               -> dados da sala (título, sistema, membros...)
///   chats/{roomId}/messages/{id} -> mensagens
///
/// Caso o usuário esteja em Modo Demonstração ou sem permissão/conexão no Firestore,
/// o serviço mantém salas e mensagens locais em memória para garantir fluidez (IHC).
class ChatService {
  ChatService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  static String? _cachedName;

  // Estado local compartilhado para fallback / demonstração imediata
  static final Map<String, ChatRoom> _localRooms = _seedRooms();
  static final Map<String, List<ChatMessage>> _localMessages = _seedMessages();
  static final StreamController<void> _localUpdates =
      StreamController<void>.broadcast();

  static Map<String, ChatRoom> _seedRooms() {
    final now = DateTime.now();
    return {
      'taverna-do-dragao': ChatRoom(
        id: 'taverna-do-dragao',
        title: 'Taverna do Dragão',
        system: 'D&D 5e',
        description: 'Campanha presencial aos sábados • Local: Taverna do Dado Dourado',
        members: const ['demo-master', 'demo-player-1', 'local-user'],
        lastMessage: 'Mestre IA: 🎲 Lembrem-se de trazer fichas de nível 3!',
        lastMessageAt: now.subtract(const Duration(minutes: 8)),
      ),
      'sombras-sobre-arkham': ChatRoom(
        id: 'sombras-sobre-arkham',
        title: 'Sombras sobre Arkham',
        system: 'Call of Cthulhu',
        description: 'Investigação de horror anos 1920 • Local: Santuário Nocturno Lounge',
        members: const ['demo-master-2', 'local-user'],
        lastMessage: 'Helena (Mestre): Nos vemos sexta às 20h na Sala 2!',
        lastMessageAt: now.subtract(const Duration(hours: 2)),
      ),
    };
  }

  static Map<String, List<ChatMessage>> _seedMessages() {
    final now = DateTime.now();
    return {
      'taverna-do-dragao': [
        ChatMessage(
          id: 'm3',
          senderId: 'ai',
          senderName: 'Mestre IA',
          text: '**Dica para a Sessão 1:** Vocês se encontrarão na **Taverna do Dado Dourado** '
              '(Av. Getúlio Vargas, 1420). Que tal cada um já definir um rumor que seu '
              'personagem ouviu sobre as Ruínas de Valdris?',
          type: ChatMessageType.ai,
          createdAt: now.subtract(const Duration(minutes: 8)),
        ),
        ChatMessage(
          id: 'm2',
          senderId: 'demo-player-1',
          senderName: 'Thorin (Paladino)',
          text: 'Confirmado! Já reservei a mesa grande lá na Taverna do Dado Dourado.',
          type: ChatMessageType.user,
          createdAt: now.subtract(const Duration(minutes: 15)),
        ),
        ChatMessage(
          id: 'm1',
          senderId: 'demo-master',
          senderName: 'Mestre Lucas',
          text: 'Bem-vindos à mesa Taverna do Dragão! Usem o botão ✨ ou digitem /ia se quiserem ideias para seus personagens.',
          type: ChatMessageType.user,
          createdAt: now.subtract(const Duration(minutes: 25)),
        ),
      ],
      'sombras-sobre-arkham': [
        ChatMessage(
          id: 'c2',
          senderId: 'demo-master-2',
          senderName: 'Helena (Mestre)',
          text: 'Nos vemos sexta às 20h na Sala 2 do Santuário Nocturno Lounge!',
          type: ChatMessageType.user,
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        ChatMessage(
          id: 'c1',
          senderId: 'system',
          senderName: 'Sistema',
          text: 'Sala criada para a mesa Sombras sobre Arkham.',
          type: ChatMessageType.system,
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
      ],
    };
  }

  FirebaseAuth? get _safeAuth {
    if (_auth != null) return _auth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _safeFirestore {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  String get currentUid => _safeAuth?.currentUser?.uid ?? 'local-user';

  /// Gera um id estável a partir do título (ex: "Taverna do Dragão" -> "taverna-do-dragao").
  static String roomIdFromTitle(String title) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const to = 'aaaaaeeeeiiiiooooouuuucn';
    var s = title.toLowerCase().trim();
    for (var i = 0; i < from.length; i++) {
      s = s.replaceAll(from[i], to[i]);
    }
    s = s.replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
    return s.isEmpty ? 'sala-${DateTime.now().millisecondsSinceEpoch}' : s;
  }

  /// Nome de exibição do usuário logado (lido do perfil no Firestore ou fallback).
  Future<String> currentUserName() async {
    if (_cachedName != null) return _cachedName!;
    final user = _safeAuth?.currentUser;
    if (user == null) return 'Aventureiro';
    try {
      final fs = _safeFirestore;
      if (fs != null) {
        final doc = await fs.collection('users').doc(user.uid).get();
        final name = (doc.data()?['name'] as String?)?.trim();
        if (name != null && name.isNotEmpty) {
          _cachedName = name;
          return _cachedName!;
        }
      }
    } catch (_) {}
    _cachedName = user.email?.split('@').first ?? 'Aventureiro';
    return _cachedName!;
  }

  static List<ChatRoom> _sortedLocalRooms() {
    final list = _localRooms.values.toList();
    list.sort((a, b) =>
        (b.lastMessageAt ?? DateTime(2000)).compareTo(a.lastMessageAt ?? DateTime(2000)));
    return list;
  }

  /// Salas das quais o usuário participa, mesclando Firestore (se disponível) e salas locais.
  Stream<List<ChatRoom>> watchMyRooms() {
    final controller = StreamController<List<ChatRoom>>();
    List<ChatRoom> remoteRooms = const [];

    void emit() {
      if (controller.isClosed) return;
      final merged = <String, ChatRoom>{
        for (final r in _sortedLocalRooms()) r.id: r,
        for (final r in remoteRooms) r.id: r,
      };
      final list = merged.values.toList()
        ..sort((a, b) => (b.lastMessageAt ?? DateTime(2000))
            .compareTo(a.lastMessageAt ?? DateTime(2000)));
      controller.add(list);
    }

    final localSub = _localUpdates.stream.listen((_) => emit());
    StreamSubscription? remoteSub;

    final fs = _safeFirestore;
    final user = _safeAuth?.currentUser;
    if (fs != null && user != null) {
      remoteSub = fs
          .collection('chats')
          .where('members', arrayContains: user.uid)
          .snapshots()
          .listen(
        (snap) {
          remoteRooms = snap.docs.map(ChatRoom.fromDoc).toList();
          emit();
        },
        onError: (_) => emit(),
      );
    }

    emit();
    controller.onCancel = () {
      localSub.cancel();
      remoteSub?.cancel();
    };
    return controller.stream;
  }

  /// Entra (ou cria) a sala de uma mesa. Retorna o id da sala.
  Future<String> joinOrCreateRoom({
    required String title,
    String system = 'D&D 5e',
    String description = '',
  }) async {
    final uid = currentUid;
    final name = await currentUserName();
    final roomId = roomIdFromTitle(title);

    // Atualiza estado local imediatamente (IHC: resposta instantânea)
    final existedLocally = _localRooms.containsKey(roomId);
    final existing = _localRooms[roomId];
    _localRooms[roomId] = ChatRoom(
      id: roomId,
      title: title,
      system: system.isNotEmpty ? system : (existing?.system ?? 'D&D 5e'),
      description: description.isNotEmpty ? description : (existing?.description ?? ''),
      members: {...?existing?.members, uid}.toList(),
      lastMessage: existing?.lastMessage ?? '$name entrou na mesa.',
      lastMessageAt: DateTime.now(),
    );
    _localMessages.putIfAbsent(roomId, () => []);
    if (!existedLocally) {
      _localMessages[roomId]!.insert(
        0,
        ChatMessage(
          id: 'sys-${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'system',
          senderName: 'Sistema',
          text: '$name entrou na mesa "$title".',
          type: ChatMessageType.system,
          createdAt: DateTime.now(),
        ),
      );
    }
    _localUpdates.add(null);

    // Tenta sincronizar com o Firestore em segundo plano
    final fs = _safeFirestore;
    final user = _safeAuth?.currentUser;
    if (fs != null && user != null) {
      try {
        final ref = fs.collection('chats').doc(roomId);
        final snap = await ref.get();
        final alreadyMember = snap.exists &&
            List<String>.from(snap.data()?['members'] ?? []).contains(uid);
        if (!snap.exists) {
          await ref.set({
            'title': title,
            'system': system,
            'description': description,
            'members': [uid],
            'createdBy': uid,
            'createdAt': FieldValue.serverTimestamp(),
            'lastMessage': '$name entrou na mesa.',
            'lastMessageAt': FieldValue.serverTimestamp(),
          });
        } else if (!alreadyMember) {
          await ref.update({
            'members': FieldValue.arrayUnion([uid]),
          });
        }
      } catch (_) {
        // Mantém funcionando localmente caso as regras do Firestore bloqueiem
      }
    }
    return roomId;
  }

  /// Mensagens de uma sala em tempo real (mais recentes primeiro).
  Stream<List<ChatMessage>> watchMessages(String roomId) {
    final controller = StreamController<List<ChatMessage>>();
    List<ChatMessage> remoteMessages = const [];

    void emit() {
      if (controller.isClosed) return;
      final local = _localMessages[roomId] ?? const [];
      if (remoteMessages.isNotEmpty) {
        controller.add(remoteMessages);
      } else {
        controller.add(List<ChatMessage>.from(local));
      }
    }

    final localSub = _localUpdates.stream.listen((_) => emit());
    StreamSubscription? remoteSub;

    final fs = _safeFirestore;
    final user = _safeAuth?.currentUser;
    if (fs != null && user != null) {
      remoteSub = fs
          .collection('chats')
          .doc(roomId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(200)
          .snapshots()
          .listen(
        (snap) {
          if (snap.docs.isNotEmpty) {
            remoteMessages = snap.docs.map(ChatMessage.fromDoc).toList();
          }
          emit();
        },
        onError: (_) => emit(),
      );
    }

    emit();
    controller.onCancel = () {
      localSub.cancel();
      remoteSub?.cancel();
    };
    return controller.stream;
  }

  /// Envia uma mensagem (de usuário, da IA ou do sistema).
  Future<void> sendMessage(
    String roomId,
    String text, {
    ChatMessageType type = ChatMessageType.user,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final senderName = switch (type) {
      ChatMessageType.ai => 'Mestre IA',
      ChatMessageType.system => 'Sistema',
      ChatMessageType.user => await currentUserName(),
    };

    final now = DateTime.now();
    final message = ChatMessage(
      id: 'local-${now.microsecondsSinceEpoch}',
      senderId: type == ChatMessageType.user ? currentUid : type.name,
      senderName: senderName,
      text: trimmed,
      type: type,
      createdAt: now,
    );

    // 1. Adiciona localmente de imediato (UI otimista)
    final list = _localMessages.putIfAbsent(roomId, () => []);
    list.insert(0, message);
    final room = _localRooms[roomId];
    if (room != null) {
      _localRooms[roomId] = ChatRoom(
        id: room.id,
        title: room.title,
        system: room.system,
        description: room.description,
        members: room.members,
        lastMessage: type == ChatMessageType.user ? '$senderName: $trimmed' : trimmed,
        lastMessageAt: now,
      );
    }
    _localUpdates.add(null);

    // 2. Sincroniza com o Firestore se autenticado
    final fs = _safeFirestore;
    final user = _safeAuth?.currentUser;
    if (fs != null && user != null) {
      try {
        final roomRef = fs.collection('chats').doc(roomId);
        await roomRef.collection('messages').add(message.toMap());
        await roomRef.update({
          'lastMessage':
              type == ChatMessageType.user ? '$senderName: $trimmed' : trimmed,
          'lastMessageAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }
  }

  /// Sai da sala.
  Future<void> leaveRoom(String roomId) async {
    _localRooms.remove(roomId);
    _localUpdates.add(null);

    final fs = _safeFirestore;
    final user = _safeAuth?.currentUser;
    if (fs != null && user != null) {
      try {
        await fs.collection('chats').doc(roomId).update({
          'members': FieldValue.arrayRemove([currentUid]),
        });
      } catch (_) {}
    }
  }

  /// Traduz erros do Firestore para mensagens amigáveis.
  static String friendlyError(Object error) {
    if (error is FirebaseException && error.code == 'permission-denied') {
      return 'Modo demonstração local ativo (regras do Firestore restritas).';
    }
    if (error is FirebaseException && error.code == 'unavailable') {
      return 'Sem conexão com o servidor. Usando chat local.';
    }
    return 'Aviso no chat: $error';
  }
}
