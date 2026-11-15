import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/rich_message_text.dart';
import '../../assistant/service/ai_game_master_service.dart';
import '../viewmodel/dice_viewmodel.dart';

class DiceRollView extends StatefulWidget {
  final bool embedded;

  const DiceRollView({super.key, this.embedded = false});

  @override
  State<DiceRollView> createState() => _DiceRollViewState();
}

class _DiceRollViewState extends State<DiceRollView> {
  final DiceRollViewModel _viewModel = DiceRollViewModel();
  final AiGameMasterService _aiService = AiGameMasterService();
  final List<int> _diceTypes = const [4, 6, 8, 10, 12, 20, 100];
  int _rollCounter = 0;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _roll() {
    HapticFeedback.mediumImpact();
    _rollCounter++;
    _viewModel.rollDice();
  }

  Future<void> _narrateLastRoll(RollResult result) async {
    final reply = await _aiService.ask(
      'Rolei ${_viewModel.quantity}d${result.diceType} e tirei ${result.total} '
      '(dados: ${result.rolls.join(", ")}). Narre o que acontece na cena de forma épica e curta!',
    );
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: Theme.of(ctx).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Narração do Mestre IA (Resultado ${result.total})',
                    style: Theme.of(ctx)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RichMessageText(reply),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final last = _viewModel.lastResult;
    final isCritHit =
        last != null && last.diceType == 20 && last.rolls.length == 1 && last.rolls.first == 20;
    final isCritFail =
        last != null && last.diceType == 20 && last.rolls.length == 1 && last.rolls.first == 1;

    return Scaffold(
      appBar: widget.embedded
          ? null
          : AppBar(
              title: const Text('Mesa de Dados'),
              centerTitle: true,
            ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Seleção dos Tipos de Dados (D4, D6, D20...)
            SizedBox(
              height: 58,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _diceTypes.length,
                itemBuilder: (context, index) {
                  final dice = _diceTypes[index];
                  final isSelected = _viewModel.selectedDice == dice;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text('D$dice'),
                      avatar: const Icon(Icons.casino, size: 18),
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        _viewModel.selectDice(dice);
                      },
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // 2. Controles de Quantidade e Modificador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'Quantidade',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            color: theme.colorScheme.primary,
                            onPressed: () => _viewModel.updateQuantity(-1),
                          ),
                          Text(
                            '${_viewModel.quantity}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            color: theme.colorScheme.primary,
                            onPressed: () => _viewModel.updateQuantity(1),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Modificador',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            color: theme.colorScheme.primary,
                            onPressed: () => _viewModel.updateModifier(-1),
                          ),
                          Text(
                            '${_viewModel.modifier >= 0 ? "+" : ""}${_viewModel.modifier}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            color: theme.colorScheme.primary,
                            onPressed: () => _viewModel.updateModifier(1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Resultado da Rolagem Atual com Animação Fluida
            Expanded(
              child: Center(
                child: last == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.casino_outlined,
                            size: 80,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Escolha os dados e toque para rolar',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Column(
                          key: ValueKey(_rollCounter),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isCritHit || isCritFail)
                              Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isCritHit
                                      ? const Color(0xFFFFD700)
                                      : theme.colorScheme.error,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isCritHit ? '✨ ACERTO CRÍTICO!' : '💀 FALHA CRÍTICA!',
                                  style: TextStyle(
                                    color: isCritHit ? const Color(0xFF261900) : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            Text(
                              '${last.total}',
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontSize: 68,
                                fontWeight: FontWeight.bold,
                                color: _getRollColor(context, last),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Dados (${last.rolls.length}d${last.diceType}): ${last.rolls.join(" + ")}'
                              '${last.modifier != 0 ? " (${last.modifier >= 0 ? '+' : ''}${last.modifier})" : ""}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: () => _narrateLastRoll(last),
                              icon: const Icon(Icons.auto_awesome, size: 16),
                              label: const Text('Narrar resultado com Mestre IA'),
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            // 4. Histórico recente de rolagens (IHC: Visibilidade do status do sistema)
            if (_viewModel.history.length > 1)
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _viewModel.history.length.clamp(0, 10),
                  itemBuilder: (_, i) {
                    final h = _viewModel.history[i];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${h.rolls.length}d${h.diceType}: ${h.total}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // 5. Botão de Ação: ROLAR DADOS
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _roll,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.casino, size: 28),
                label: Text(
                  'ROLAR ${_viewModel.quantity}D${_viewModel.selectedDice} ${_viewModel.modifier != 0 ? "(${_viewModel.modifier >= 0 ? '+' : ''}${_viewModel.modifier})" : ""}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRollColor(BuildContext context, RollResult result) {
    final theme = Theme.of(context);

    if (result.diceType == 20 && result.rolls.length == 1) {
      if (result.rolls.first == 20) {
        return theme.colorScheme.secondary;
      }
      if (result.rolls.first == 1) {
        return theme.colorScheme.error;
      }
    }
    return theme.colorScheme.onSurface;
  }
}
