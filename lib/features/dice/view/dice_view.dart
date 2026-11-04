import 'package:flutter/material.dart';
import '../viewmodel/dice_viewmodel.dart';

class DiceRollView extends StatefulWidget {
  const DiceRollView({super.key});

  @override
  State<DiceRollView> createState() => _DiceRollViewState();
}

class _DiceRollViewState extends State<DiceRollView> {
  final DiceRollViewModel _viewModel = DiceRollViewModel();
  final List<int> _diceTypes = const [4, 6, 8, 10, 12, 20, 100];

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final last = _viewModel.lastResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesa de Dados'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Seleção dos Tipos de Dados (D4, D6, D20...)
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      onSelected: (_) => _viewModel.selectDice(dice),
                    ),
                  );
                },
              ),
            ),

            const Divider(),

            // 2. Controles de Quantidade e Modificador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Quantidade de dados
                  Column(
                    children: [
                      Text(
                        'Qtd Dados',
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

                  // Modificador (+/-)
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

            // 3. Resultado da Rolagem Atual
            Expanded(
              child: Center(
                child: last == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.casino_outlined,
                            size: 80,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Escolha os dados e aperte para rolar',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${last.total}',
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: _getRollColor(context, last),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dados: ${last.rolls.join(" + ")} ${_viewModel.modifier != 0 ? "(${_viewModel.modifier >= 0 ? '+' : ''}${_viewModel.modifier})" : ""}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            // 4. Botão de Ação: ROLAR DADOS
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _viewModel.rollDice,
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

  // Cor do texto de resultado para D20 (Acerto Crítico / Falha Crítica)
  Color _getRollColor(BuildContext context, RollResult result) {
    final theme = Theme.of(context);

    if (result.diceType == 20 && result.rolls.length == 1) {
      if (result.rolls.first == 20) {
        // Verde de acerto crítico (usando a cor secondary do tema como destaque ou tom padrão verde)
        return theme.colorScheme.secondary;
      }
      if (result.rolls.first == 1) {
        // Vermelho de falha crítica
        return theme.colorScheme.error;
      }
    }
    return theme.colorScheme.onSurface;
  }
}