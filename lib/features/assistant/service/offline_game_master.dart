// lib/features/assistant/service/offline_game_master.dart
import 'dart:math';

/// Mestre de reserva que funciona SEM internet / SEM IA na nuvem.
///
/// É usado automaticamente quando o Firebase AI Logic (Gemini) não está
/// disponível, para que o assistente continue útil durante testes.
class OfflineGameMaster {
  OfflineGameMaster({Random? random}) : _rng = random ?? Random();

  final Random _rng;

  T _pick<T>(List<T> list) => list[_rng.nextInt(list.length)];

  static const _names = [
    'Borin Martelo-Rubro', 'Lyra Folha-de-Prata', 'Kael, o Andarilho',
    'Madame Odete', 'Thorne Vasquez', 'Irmã Celeste', 'Gorm, o Ferreiro',
    'Zara Olhos-de-Corvo',
  ];
  static const _roles = [
    'taverneiro desconfiado', 'mercadora de relíquias', 'guarda corrupto',
    'sacerdotisa em fuga', 'bardo fofoqueiro', 'caçador de recompensas',
    'alquimista excêntrico', 'nobre arruinado',
  ];
  static const _quirks = [
    'fala sempre em rimas', 'coleciona dentes de dragão',
    'tem medo irracional de gatos', 'nunca olha nos olhos',
    'ri nervosamente quando mente', 'carrega um mapa que não deixa ninguém ver',
  ];
  static const _secrets = [
    'deve dinheiro à guilda dos ladrões', 'é um espião da coroa',
    'sabe onde está o artefato perdido', 'é parente distante do vilão',
    'foi amaldiçoado e só tem 7 dias de vida',
  ];
  static const _places = [
    'uma taverna enfumaçada chamada "O Javali Bêbado"',
    'as ruínas de um templo coberto de musgo',
    'uma estrada estreita na floresta sob neblina densa',
    'o mercado lotado da cidade portuária',
    'a entrada de uma caverna que exala ar quente',
  ];
  static const _hooks = [
    'um grito ecoa ao longe, seguido de silêncio absoluto',
    'um estranho encapuzado deixa um bilhete na sua mesa e some',
    'o chão treme levemente, como se algo enorme se movesse abaixo',
    'um corvo pousa à sua frente com um anel preso à pata',
    'as tochas se apagam todas ao mesmo tempo',
  ];
  static const _enemies = [
    '3 goblins armados com lanças improvisadas',
    '1 lobo atroz e 2 lobos comuns',
    '2 esqueletos guerreiros e 1 cultista',
    '1 ogro faminto que exige “pedágio”',
    '4 bandidos liderados por uma arqueira veterana',
  ];
  static const _twists = [
    'no meio do combate, um dos inimigos implora por ajuda: está sendo forçado',
    'o terreno é instável — falhar em um teste de Destreza derruba o personagem',
    'reforços chegam na 3ª rodada, a menos que alguém feche o portão',
    'o líder foge com um item importante assim que perde metade da vida',
  ];
  static const _quests = [
    'Resgatar a filha do prefeito, sequestrada por cultistas que vivem nos esgotos.',
    'Escoltar uma caravana de especiarias através do Desfiladeiro dos Ventos.',
    'Descobrir por que os poços da vila estão secando da noite para o dia.',
    'Recuperar um tomo proibido roubado da biblioteca do mago local.',
    'Investigar luzes estranhas que surgem no cemitério toda lua nova.',
  ];
  static const _playerTips = [
    'Dê ao seu personagem um objetivo pessoal e um medo — isso facilita a interpretação.',
    'Descreva COMO você faz a ação, não só o que faz. O mestre pode dar bônus!',
    'Converse com NPCs: muitas vezes eles têm pistas que evitam combates difíceis.',
    'Combine táticas com o grupo antes do combate (quem segura a linha de frente?).',
    'Anote nomes, lugares e pistas — a memória da mesa é a sua melhor arma.',
    'Use o ambiente: lustres, barris, portas e terreno elevado podem virar o jogo.',
  ];
  static const _masterTips = [
    'Termine cada sessão com um gancho: um mistério ou perigo iminente.',
    'Use a regra do “Sim, e...” para recompensar a criatividade dos jogadores.',
    'Prepare situações, não roteiros: deixe os jogadores escolherem o caminho.',
    'Dê a cada jogador um momento de destaque por sessão.',
    'Use descrições com 3 sentidos (visão, som, cheiro) para dar vida às cenas.',
    'Se a mesa travar, faça algo acontecer: um NPC chega, um alarme soa...',
  ];

  String _options() {
    final opts = [
      'Investigar o local com atenção (teste de Percepção/Investigação)',
      'Conversar com alguém próximo para obter informações',
      'Seguir em frente com cautela, armas em punho',
      'Preparar uma emboscada ou um plano com o grupo',
      'Usar uma magia ou habilidade especial do seu personagem',
    ]..shuffle(_rng);
    return '\n\n**O que você faz?**\n'
        '1. ${opts[0]}\n2. ${opts[1]}\n3. ${opts[2]}\n'
        '…ou descreva qualquer outra ação!';
  }

  String npc() => '**NPC gerado:** ${_pick(_names)}, ${_pick(_roles)}.\n'
      '- Peculiaridade: ${_pick(_quirks)}.\n'
      '- Segredo: ${_pick(_secrets)}.\n\n'
      'Dica: deixe os jogadores descobrirem o segredo aos poucos.';

  String encounter() => '**Encontro:** ${_pick(_enemies)}.\n'
      '- Local: ${_pick(_places)}.\n'
      '- Reviravolta: ${_pick(_twists)}.\n\n'
      '🎲 Peçam iniciativa: cada um rola 1d20 + Destreza.';

  String quest() => '**Ideia de missão:** ${_pick(_quests)}\n\n'
      'Recompensa sugerida: ouro, um favor de um NPC poderoso ou um item mágico menor.';

  String tips({bool forMaster = false}) {
    final list = [...(forMaster ? _masterTips : _playerTips)]..shuffle(_rng);
    return '**Dicas ${forMaster ? 'para o Mestre' : 'para Jogadores'}:**\n'
        '- ${list[0]}\n- ${list[1]}\n- ${list[2]}';
  }

  String startAdventure(String system) =>
      '**Uma nova aventura de $system começa!**\n\n'
      'Vocês estão em ${_pick(_places)}. De repente, ${_pick(_hooks)}.'
      '${_options()}';

  String capabilities() => '**O que eu posso fazer por você:**\n'
      '- 🧙 **Conduzir uma aventura** como Mestre, narrando cenas e dando opções.\n'
      '- 🎲 **Interpretar suas rolagens** de dados e dizer o resultado da ação.\n'
      '- 👤 **Criar NPCs** com personalidade e segredos.\n'
      '- ⚔️ **Montar encontros** e combates equilibrados.\n'
      '- 🗺️ **Sugerir missões**, ganchos e reviravoltas.\n'
      '- 📖 **Explicar regras** de forma simples.\n'
      '- 💡 **Dar dicas** para jogadores e mestres.\n'
      '- 🧩 **Ajudar a criar personagens** (história, motivação, classe).';

  String _rollResult(int value) {
    if (value >= 20) {
      return '**Acerto crítico!** Você executa a ação de forma espetacular — '
          'e ainda nota um detalhe que ninguém mais viu.';
    }
    if (value >= 15) return '**Sucesso!** Sua ação funciona exatamente como planejado.';
    if (value >= 10) {
      return '**Sucesso parcial.** Você consegue, mas com um custo: '
          'faz barulho, perde tempo ou se expõe ao perigo.';
    }
    if (value > 1) {
      return '**Falha.** As coisas não saem como esperado e a situação se complica.';
    }
    return '**Falha crítica!** Algo dá muito errado… prepare-se para as consequências.';
  }

  /// Gera uma resposta com base em palavras-chave da mensagem.
  String reply(String message, {String system = 'D&D 5e', bool tipsMode = false}) {
    final m = message.toLowerCase();

    // Remove notação de dados (ex: "1d20", "d6") para não confundir com o resultado
    final noDice = m.replaceAll(RegExp(r'\b\d*d\d+\b'), ' ');
    final roll = RegExp(r'(?:rolei|tirei|resultado|role[iu]?)[^0-9]*(\d{1,3})').allMatches(noDice);
    if (roll.isNotEmpty) {
      final v = int.tryParse(roll.last.group(1)!) ?? 10;
      return '🎲 Resultado **$v**. ${_rollResult(v)}${_options()}';
    }
    if (m.contains('o que') && (m.contains('pode') || m.contains('consegue')) &&
        (m.contains('ia') || m.contains('você') || m.contains('voce'))) {
      return capabilities();
    }
    if (m.contains('npc') || m.contains('personagem não') || m.contains('vilão')) return npc();
    if (m.contains('encontro') || m.contains('combate') || m.contains('luta') ||
        m.contains('inimig')) {
      return encounter();
    }
    if (m.contains('missão') || m.contains('missao') || m.contains('quest') ||
        m.contains('gancho')) {
      return quest();
    }
    if (m.contains('dica') || m.contains('conselho') || m.contains('ajuda')) {
      return tips(forMaster: m.contains('mestre'));
    }
    if (m.contains('regra') || m.contains('como funciona')) {
      return '**Regra de ouro:** para resolver uma ação incerta, role 1d20 e some o '
          'modificador do atributo (e proficiência, se houver). Compare com a '
          'Classe de Dificuldade (CD): 10 fácil, 15 médio, 20 difícil.\n\n'
          '(Modo offline: para regras específicas de $system, ative a IA na nuvem.)';
    }
    if (m.contains('começar') || m.contains('comecar') || m.contains('aventura') ||
        m.contains('iniciar')) {
      return startAdventure(system);
    }
    if (tipsMode) return tips();

    return 'Você ${_pick(['avança', 'age', 'segue seu plano'])}. '
        'Ao seu redor, ${_pick(_hooks)}.${_options()}';
  }
}
