// lib/features/assistant/view/assistant_view.dart
import 'package:flutter/material.dart';
import '../../../core/widgets/rich_message_text.dart';
import '../../dice/view/dice_view.dart';
import '../service/ai_game_master_service.dart';
import '../viewmodel/assistant_viewmodel.dart';

/// Aba "Assistente": IA que guia o jogo (Mestre IA) e dá dicas.
class AssistantView extends StatefulWidget {
  const AssistantView({super.key, this.viewModel});

  /// Permite injetar um ViewModel (útil em testes).
  final AssistantViewModel? viewModel;

  @override
  State<AssistantView> createState() => _AssistantViewState();
}

class _AssistantViewState extends State<AssistantView> {
  late final AssistantViewModel _vm;
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _showDiceTab = false;

  @override
  void initState() {
    super.initState();
    _vm = widget.viewModel ?? AssistantViewModel();
    _vm.addListener(_onChange);
  }

  void _onChange() {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _vm.removeListener(_onChange);
    if (widget.viewModel == null) _vm.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final value = text ?? _input.text;
    if (value.trim().isEmpty) return;
    _input.clear();
    _vm.send(value);
  }

  Future<void> _pickDice() async {
    final sides = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Rolar dado e enviar para a IA',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final d in const [4, 6, 8, 10, 12, 20, 100])
                    ActionChip(
                      avatar: const Icon(Icons.casino, size: 18),
                      label: Text('D$d'),
                      onPressed: () => Navigator.pop(ctx, d),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (sides != null) _vm.rollAndSend(sides);
  }

  void _showCapabilities() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (ctx, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text('O que a IA pode fazer por você',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Toque em um exemplo para enviá-lo agora.'),
            const SizedBox(height: 12),
            for (final c in _capabilities)
              Card(
                child: ListTile(
                  leading: Icon(c.$1, color: Theme.of(ctx).colorScheme.primary),
                  title: Text(c.$2, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Ex.: "${c.$3}"'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _showDiceTab = false);
                    _send(c.$3);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  static const List<(IconData, String, String, AssistantMode?)> _capabilities = [
    (Icons.auto_stories, 'Mestrar uma aventura solo',
        'Comece uma aventura de fantasia sombria para mim', AssistantMode.narrator),
    (Icons.casino, 'Interpretar rolagens de dados',
        'Rolei 17 no teste de Furtividade', AssistantMode.narrator),
    (Icons.alt_route, 'Sugerir o que fazer quando você travar',
        'Estou preso nessa cena, quais são minhas opções?', AssistantMode.narrator),
    (Icons.person_add, 'Criar NPCs', 'Crie um vilão memorável', AssistantMode.tips),
    (Icons.shield, 'Montar encontros e combates',
        'Monte um combate para 4 jogadores de nível 5', AssistantMode.tips),
    (Icons.map, 'Criar missões e ganchos',
        'Me dê 3 ganchos de aventura em uma cidade portuária', AssistantMode.tips),
    (Icons.menu_book, 'Explicar regras',
        'Como funciona vantagem e desvantagem?', AssistantMode.tips),
    (Icons.badge, 'Ajudar a criar personagens',
        'Me ajude a criar um ladino com uma história trágica', AssistantMode.tips),
    (Icons.lightbulb, 'Dar dicas para jogadores e mestres',
        'Como deixo minhas sessões mais imersivas?', AssistantMode.tips),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_showDiceTab ? 'Mesa de Dados' : 'Mestre'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Como o Mestre pode ajudar?',
            icon: const Icon(Icons.help_outline),
            onPressed: _showCapabilities,
          ),
          if (!_showDiceTab)
            IconButton(
              tooltip: 'Nova conversa',
              icon: const Icon(Icons.refresh),
              onPressed: _vm.isLoading ? null : _vm.newConversation,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Seletor Integrado: Mestre | Dados (tudo unificado em Mestre)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'narrator',
                      label: Text('Mestre'),
                      icon: Icon(Icons.auto_stories, size: 18),
                    ),
                    ButtonSegment(
                      value: 'dice',
                      label: Text('Dados'),
                      icon: Icon(Icons.casino_outlined, size: 18),
                    ),
                  ],
                  selected: {
                    _showDiceTab ? 'dice' : 'narrator',
                  },
                  onSelectionChanged: _vm.isLoading
                      ? null
                      : (s) {
                          final choice = s.first;
                          setState(() => _showDiceTab = (choice == 'dice'));
                        },
                  style: const ButtonStyle(visualDensity: VisualDensity.compact),
                ),
              ),
            ),
            if (_showDiceTab)
              const Expanded(child: DiceRollView(embedded: true))
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.menu_book, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    const Text('Sistema:'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _vm.system,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        borderRadius: BorderRadius.circular(12),
                        items: [
                          for (final s in AssistantViewModel.systems)
                            DropdownMenuItem(value: s, child: Text(s)),
                        ],
                        onChanged:
                            _vm.isLoading ? null : (s) => s != null ? _vm.setSystem(s) : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (_vm.isOffline) _buildOfflineBanner(theme),

              // Mensagens
              Expanded(
                child: _vm.messages.isEmpty
                    ? _buildWelcome(theme)
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(12),
                        itemCount: _vm.messages.length,
                        itemBuilder: (_, i) => _buildBubble(_vm.messages[i], theme),
                      ),
              ),

              // Sugestões rápidas
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (final s in _vm.suggestions)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: Icon(s.icon, size: 18),
                          label: Text(s.label),
                          onPressed: _vm.isLoading ? null : () => _send(s.prompt),
                        ),
                      ),
                  ],
                ),
              ),

              // Entrada de texto
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Rolar dado',
                      icon: const Icon(Icons.casino),
                      onPressed: _vm.isLoading ? null : _pickDice,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _input,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Descreva sua ação ou peça NPC, dica, regra…',
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filled(
                      tooltip: 'Enviar',
                      icon: _vm.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send),
                      onPressed: _vm.isLoading ? null : _send,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner(ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 18, color: Colors.brown),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Modo offline: usando o mestre local. Ative o Firebase AI Logic '
              'no console para respostas completas do Gemini.',
              style: TextStyle(fontSize: 12, color: Colors.brown),
            ),
          ),
          TextButton(onPressed: _vm.retryOnline, child: const Text('Tentar')),
        ],
      ),
    );
  }

  Widget _buildWelcome(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Icon(Icons.auto_stories, size: 64, color: theme.colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          'Mestre IA',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Eu conduzo a aventura, interpreto NPCs, rolo dados, crio encontros, '
          'missões e tiro dúvidas de regras e dicas para sua mesa (${_vm.system}).',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Center(
          child: OutlinedButton.icon(
            onPressed: _showCapabilities,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Ver tudo o que a IA pode fazer'),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text('Ou toque em uma sugestão abaixo 👇',
              style: theme.textTheme.bodySmall),
        ),
      ],
    );
  }

  Widget _buildBubble(AssistantMessage msg, ThemeData theme) {
    final isUser = msg.fromUser;
    final waiting = !isUser && msg.text.isEmpty;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text('Mestre IA',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary)),
                  ],
                ),
              ),
            waiting
                ? const Text('Pensando… 🎲', style: TextStyle(fontStyle: FontStyle.italic))
                : RichMessageText(
                    msg.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
