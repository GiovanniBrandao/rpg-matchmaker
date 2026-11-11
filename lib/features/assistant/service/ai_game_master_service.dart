// lib/features/assistant/service/ai_game_master_service.dart
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'offline_game_master.dart';

/// Modos de atuação do assistente.
enum AssistantMode {
  narrator('Mestre IA', 'Conduz a aventura, narra cenas e dá opções'),
  tips('Dicas', 'Ajuda, regras e ideias para jogadores e mestres');

  final String label;
  final String description;
  const AssistantMode(this.label, this.description);
}

/// Integração com o Gemini através do Firebase AI Logic.
///
/// Se a IA na nuvem falhar (serviço não ativado no console, sem internet etc.),
/// o serviço passa automaticamente para o [OfflineGameMaster].
class AiGameMasterService {
  AiGameMasterService({OfflineGameMaster? offline})
      : _offline = offline ?? OfflineGameMaster();

  /// Modelo suportado atualmente pelo Firebase AI Logic.
  static const String modelName = 'gemini-3.8-flash';

  final OfflineGameMaster _offline;
  ChatSession? _session;
  String _system = 'D&D 5e';
  AssistantMode _mode = AssistantMode.narrator;

  bool isOffline = false;
  String? lastError;

  static String systemPrompt(String system, AssistantMode mode) {
    const base = 'Você é o "Mestre IA", assistente do app RPG Matchmaker. '
        'Responda SEMPRE em português do Brasil, de forma envolvente e concisa '
        '(até ~180 palavras). Não use títulos markdown (#); pode usar **negrito** '
        'e listas com "-" ou números. Evite conteúdo impróprio.';
    final sys = 'O sistema de RPG da mesa é: $system. Respeite suas regras e clima.';
    final modeText = switch (mode) {
      AssistantMode.narrator =>
        'MODO MESTRE: você conduz a aventura como Mestre do Jogo. Descreva a cena '
            'com detalhes sensoriais, interprete NPCs e reaja às ações do jogador. '
            'Quando uma ação for incerta, peça uma rolagem no formato '
            '"🎲 Role 1d20 + <atributo> (CD <n>)". Quando o jogador informar o '
            'resultado, narre a consequência. Termine CADA resposta com '
            '"**O que você faz?**" e 2 a 4 opções numeradas de ações possíveis, '
            'lembrando que ele pode fazer qualquer outra coisa.',
      AssistantMode.tips =>
        'MODO DICAS: você é um conselheiro experiente de RPG. Dê dicas práticas '
            'para jogadores e mestres, explique regras de forma simples, gere NPCs, '
            'encontros, missões, nomes e ideias de personagens. Sempre que fizer '
            'sentido, finalize sugerindo 1 ou 2 próximos passos que o usuário pode '
            'pedir a você.',
    };
    return '$base\n$sys\n$modeText';
  }

  GenerativeModel _buildModel() {
    final ai = FirebaseAI.googleAI(auth: FirebaseAuth.instance);
    return ai.generativeModel(
      model: modelName,
      systemInstruction: Content.system(systemPrompt(_system, _mode)),
      generationConfig: GenerationConfig(temperature: 0.9, maxOutputTokens: 900),
    );
  }

  /// Inicia (ou reinicia) uma conversa com o sistema/modo escolhido.
  void startSession({required String system, required AssistantMode mode}) {
    _system = system;
    _mode = mode;
    try {
      _session = _buildModel().startChat();
    } catch (e) {
      _session = null;
      isOffline = true;
      lastError = '$e';
    }
  }

  /// Envia uma mensagem e devolve a resposta em partes (streaming).
  Stream<String> send(String text) async* {
    if (_session == null && !isOffline) startSession(system: _system, mode: _mode);

    if (!isOffline && _session != null) {
      var gotSomething = false;
      try {
        await for (final chunk in _session!.sendMessageStream(Content.text(text))) {
          final t = chunk.text;
          if (t != null && t.isNotEmpty) {
            gotSomething = true;
            yield t;
          }
        }
        if (gotSomething) return;
      } catch (e) {
        lastError = '$e';
        isOffline = true;
        if (gotSomething) return;
      }
    }

    yield _offline.reply(text, system: _system, tipsMode: _mode == AssistantMode.tips);
  }

  /// Pergunta avulsa (sem histórico) — usada pelo chat das mesas.
  Future<String> ask(String prompt, {String system = 'D&D 5e'}) async {
    if (!isOffline) {
      try {
        final ai = FirebaseAI.googleAI(auth: FirebaseAuth.instance);
        final model = ai.generativeModel(
          model: modelName,
          systemInstruction: Content.system(systemPrompt(system, AssistantMode.tips)),
          generationConfig: GenerationConfig(temperature: 0.8, maxOutputTokens: 600),
        );
        final res = await model.generateContent([Content.text(prompt)]);
        final t = res.text;
        if (t != null && t.trim().isNotEmpty) return t.trim();
      } catch (e) {
        lastError = '$e';
        isOffline = true;
      }
    }
    return _offline.reply(prompt, system: system, tipsMode: true);
  }

  /// Tenta voltar a usar a IA na nuvem.
  void retryOnline() {
    isOffline = false;
    lastError = null;
    startSession(system: _system, mode: _mode);
  }
}
