import 'dart:math';
import 'package:flutter/material.dart';

enum Mode { player, master }

class SwipeView extends StatefulWidget {
  const SwipeView({super.key});

  @override
  State<SwipeView> createState() => _SwipeViewState();
}

class _SwipeViewState extends State<SwipeView> with SingleTickerProviderStateMixin {
  Mode _currentMode = Mode.player;

  // Lista mockada de cards para o Swipe
  final List<Map<String, String>> _cards = [
    {
      'title': 'Taverna do Dragão',
      'system': 'D&D 5e',
      'location': 'Presencial • Bauru, SP (5 km)',
      'desc': 'Procurando 2 jogadores para campanha longa aos sábados.',
      'image': '',
    },
    {
      'title': 'Aelar, o Mago',
      'system': 'Tormenta20',
      'location': 'Online • Discord',
      'desc': 'Jogador focado em interpretação, nível 3, disponível fins de semana.',
      'image': '',
    },
    {
      'title': 'Sombras sobre Arkham',
      'system': 'Call of Cthulhu',
      'location': 'Presencial • Piracicaba, SP (12 km)',
      'desc': 'Mesa investigativa de terror dos anos 1920.',
      'image': '',
    },
  ];

  // Variáveis de Controle da Física de Arraste
  Offset _position = Offset.zero;
  bool _isDragging = false;
  Size _screenSize = Size.zero;

  // Controlador para disparar animação manual via Botões inferiores
  late AnimationController _animController;
  late Animation<Offset> _swipeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextCard();
        _animController.reset();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Avança para o próximo card
  void _nextCard() {
    if (_cards.isEmpty) return;
    setState(() {
      _cards.removeLast();
      _position = Offset.zero;
    });
  }

  // Ações ativadas ao Soltar o Card ou Clicar nos Botões
  void _swipeLeft() {
    final theme = Theme.of(context);
    _swipeAnimation = Tween<Offset>(
      begin: _position,
      end: Offset(-_screenSize.width * 2, _position.dy),
    ).animate(_animController);

    _animController.forward();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Passou a oportunidade'),
        duration: const Duration(milliseconds: 800),
        backgroundColor: theme.colorScheme.error,
      ),
    );
  }

  void _swipeRight() {
    final theme = Theme.of(context);
    _swipeAnimation = Tween<Offset>(
      begin: _position,
      end: Offset(_screenSize.width * 2, _position.dy),
    ).animate(_animController);

    _animController.forward();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Solicitação enviada!'),
        duration: const Duration(milliseconds: 1000),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. Barra Superior: Switch de Modo e Ícone de Chat
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SegmentedButton<Mode>(
                    segments: const [
                      ButtonSegment<Mode>(
                        value: Mode.player,
                        label: Text('Jogador'),
                        icon: Icon(Icons.person, size: 18),
                      ),
                      ButtonSegment<Mode>(
                        value: Mode.master,
                        label: Text('Mestre'),
                        icon: Icon(Icons.shield, size: 18),
                      ),
                    ],
                    selected: {_currentMode},
                    onSelectionChanged: (Set<Mode> newSelection) {
                      setState(() {
                        _currentMode = newSelection.first;
                      });
                    },
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chat_bubble_outline, size: 28, color: theme.colorScheme.primary),
                    onPressed: () {
                      // NAVEGAÇÃO: Abrir conversas/matches
                    },
                  ),
                ],
              ),
            ),

            // 2. Área Central: Pilha de Cards de Match estilo Tinder/Reigns
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _cards.isEmpty
                    ? _buildEmptyState(theme)
                    : Stack(
                        children: _cards.asMap().entries.map((entry) {
                          final index = entry.key;
                          final cardData = entry.value;

                          // Renderiza apenas o card do topo como interativo
                          if (index == _cards.length - 1) {
                            return _buildTopCard(cardData, theme);
                          }

                          // Cards do fundo ficam estáticos abaixo
                          return _buildBackgroundCard(cardData, theme);
                        }).toList(),
                      ),
              ),
            ),

            // 3. Botões de Ação Flutuantes (Disparam a Animação sem arrastar)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botão Recusar / Passar
                  FloatingActionButton.small(
                    heroTag: 'pass_btn',
                    onPressed: _cards.isEmpty || _animController.isAnimating ? null : _swipeLeft,
                    backgroundColor: theme.colorScheme.surface,
                    child: Icon(Icons.close, color: theme.colorScheme.error, size: 24),
                  ),

                  // Botão Detalhes / Ficha Completa
                  FloatingActionButton.small(
                    heroTag: 'info_btn',
                    onPressed: _cards.isEmpty
                        ? null
                        : () {
                            // ABRIR MODAL: Exibe a ficha/detalhes completos do card atual
                          },
                    backgroundColor: theme.colorScheme.surface,
                    child: Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 24),
                  ),

                  // Botão Aceitar / Quero Jogar
                  FloatingActionButton(
                    heroTag: 'match_btn',
                    onPressed: _cards.isEmpty || _animController.isAnimating ? null : _swipeRight,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(Icons.casino, color: theme.colorScheme.onPrimary, size: 30),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card do Topo (Com suporte a gestos e animação)
  Widget _buildTopCard(Map<String, String> cardData, ThemeData theme) {
    // Calculo do ângulo de rotação proporcional ao deslocamento X
    final double angle = (_position.dx / _screenSize.width) * (pi / 12);

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final currentOffset = _animController.isAnimating ? _swipeAnimation.value : _position;

        return Transform.translate(
          offset: currentOffset,
          child: Transform.rotate(
            angle: _animController.isAnimating ? angle * 2 : angle,
            child: GestureDetector(
              onPanStart: (details) {
                setState(() => _isDragging = true);
              },
              onPanUpdate: (details) {
                setState(() {
                  _position += details.delta;
                });
              },
              onPanEnd: (details) {
                setState(() => _isDragging = false);

                // Threshold (limiar) para considerar swipe
                final threshold = _screenSize.width * 0.35;

                if (_position.dx > threshold) {
                  _swipeRight();
                } else if (_position.dx < -threshold) {
                  _swipeLeft();
                } else {
                  // Reseta para o centro se não arrastou o suficiente
                  setState(() {
                    _position = Offset.zero;
                  });
                }
              },
              child: Stack(
                children: [
                  _buildCardContent(cardData, theme),
                  // Overlay visual (Feedback de Recusar/Aceitar)
                  if (_position.dx != 0 && !_animController.isAnimating) _buildSwipeOverlay(theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Card de Fundo (Apenas visualização em escala menor)
  Widget _buildBackgroundCard(Map<String, String> cardData, ThemeData theme) {
    return Transform.scale(
      scale: 0.95,
      child: _buildCardContent(cardData, theme),
    );
  }

  // Estrutura Visual do Card
  Widget _buildCardContent(Map<String, String> cardData, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Imagem de Fundo (Ou Placeholder do Tema)
            Positioned.fill(
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    _currentMode == Mode.player ? Icons.castle_outlined : Icons.person_outline,
                    size: 80,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            // Gradiente Escuro para Leitura de Texto
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),

            // Dados Informativos do Card
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cardData['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          cardData['system']!,
                          style: TextStyle(
                            color: theme.colorScheme.onSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: theme.colorScheme.secondary,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        cardData['location']!,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cardData['desc']!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Overlay de Feedback de Gestos (Etiquetas "ACEITAR" / "RECUSAR")
  Widget _buildSwipeOverlay(ThemeData theme) {
    final isRight = _position.dx > 0;
    final opacity = (_position.dx.abs() / (_screenSize.width * 0.3)).clamp(0.0, 1.0);

    return Positioned(
      top: 40,
      left: isRight ? 20 : null,
      right: isRight ? null : 20,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: isRight ? -0.2 : 0.2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isRight ? Color.fromARGB(255, 236, 202, 7) : theme.colorScheme.error,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withValues(alpha: 0.3),
            ),
            child: Text(
              isRight ? 'ACEITAR' : 'PASSAR',
              style: TextStyle(
                color: isRight ? Color.fromARGB(255, 236, 202, 7) : theme.colorScheme.error,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Estado para quando acabam os cards disponíveis
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_off_outlined,
            size: 72,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma mesa ou jogador por perto!',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente mudar o raio de distância ou alternar o modo no topo.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}