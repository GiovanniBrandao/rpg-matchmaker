// lib/features/assistant/viewmodel/assistant_viewmodel.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../service/ai_game_master_service.dart';

class AssistantMessage {
  AssistantMessage({required this.fromUser, required this.text});
  final bool fromUser;
  String text;
}

/// Sugestão rápida exibida como chip (rótulo curto + prompt enviado à IA).
class AssistantSuggestion {
  const AssistantSuggestion(this.icon, this.label, this.prompt);
  final IconData icon;
  final String label;
  final String prompt;
}

class AssistantViewModel extends ChangeNotifier {
  AssistantViewModel({AiGameMasterService? service})
      : _service = service ?? AiGameMasterService() {
    _service.startSession(system: _system, mode: _mode);
  }

  final AiGameMasterService _service;
  final Random _rng = Random();

  static const List<String> systems = [
    'D&D 5e', 'Tormenta20', 'Call of Cthulhu',
    'Pathfinder 2e', 'Vampiro: A Máscara', 'Ordem Paranormal',
  ];

  final List<AssistantMessage> messages = [];
  AssistantMode _mode = AssistantMode.narrator;
  String _system = systems.first;
  bool _isLoading = false;
  bool _disposed = false;

  AssistantMode get mode => _mode;
  String get system => _system;
  bool get isLoading => _isLoading;
  bool get isOffline => _service.isOffline;
  String? get lastError => _service.lastError;

  /// Sugestões rápidas unificadas no Mestre (narrativa + dicas + criação).
  List<AssistantSuggestion> get suggestions => const [
        AssistantSuggestion(Icons.play_arrow, 'Começar aventura',
            'Comece uma nova aventura curta para mim. Apresente a cena inicial.'),
        AssistantSuggestion(Icons.auto_awesome, 'O que a IA faz?',
            'O que você, IA, pode fazer para me ajudar no RPG? Liste exemplos de pedidos.'),
        AssistantSuggestion(Icons.search, 'Investigar',
            'Eu investigo o local com atenção, procurando pistas.'),
        AssistantSuggestion(Icons.record_voice_over, 'Falar com NPC',
            'Eu procuro alguém por perto para conversar e pedir informações.'),
        AssistantSuggestion(Icons.flash_on, 'Atacar!',
            'Eu saco minha arma e parto para o ataque!'),
        AssistantSuggestion(Icons.person_add, 'Criar NPC',
            'Crie um NPC interessante com nome, aparência, personalidade e um segredo.'),
        AssistantSuggestion(Icons.shield, 'Criar encontro',
            'Monte um encontro de combate equilibrado para 4 personagens de nível 3.'),
        AssistantSuggestion(Icons.map, 'Ideia de missão',
            'Me dê uma ideia de missão com gancho, complicação e recompensa.'),
        AssistantSuggestion(Icons.lightbulb, 'Dicas p/ jogador',
            'Me dê dicas para ser um jogador melhor na mesa.'),
        AssistantSuggestion(Icons.menu_book, 'Dicas p/ mestre',
            'Me dê dicas para mestrar uma sessão divertida.'),
        AssistantSuggestion(Icons.badge, 'Criar personagem',
            'Me ajude a criar um personagem: sugira conceito, classe, história e motivação.'),
      ];

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void setMode(AssistantMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    _restart();
  }

  void setSystem(String system) {
    if (system == _system) return;
    _system = system;
    _restart();
  }

  void newConversation() => _restart();

  void retryOnline() {
    _service.retryOnline();
    _notify();
  }

  void _restart() {
    messages.clear();
    _service.startSession(system: _system, mode: _mode);
    _notify();
  }

  /// Rola um dado e envia o resultado para a IA interpretar.
  Future<int> rollAndSend(int sides) async {
    final value = _rng.nextInt(sides) + 1;
    await send('🎲 Rolei 1d$sides e tirei $value.');
    return value;
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    messages.add(AssistantMessage(fromUser: true, text: trimmed));
    final reply = AssistantMessage(fromUser: false, text: '');
    messages.add(reply);
    _isLoading = true;
    _notify();

    try {
      await for (final chunk in _service.send(trimmed)) {
        reply.text += chunk;
        _notify();
      }
    } catch (e) {
      reply.text = 'Não consegui responder agora. Tente novamente. ($e)';
    } finally {
      if (reply.text.trim().isEmpty) {
        reply.text = 'Hmm… fiquei sem palavras. Tente reformular o pedido.';
      }
      _isLoading = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
