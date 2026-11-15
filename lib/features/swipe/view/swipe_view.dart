// lib/features/swipe/view/swipe_view.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../model/swipe_model.dart';
import '../viewmodel/swipe_viewmodel.dart';

class SwipeView extends StatefulWidget {
  const SwipeView({super.key});

  @override
  State<SwipeView> createState() => _SwipeViewState();
}

class _SwipeViewState extends State<SwipeView> with SingleTickerProviderStateMixin {
  final SwipeViewModel _viewModel = SwipeViewModel();

  Offset _position = Offset.zero;
  bool _isDragging = false;
  Size _screenSize = Size.zero;

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
        _viewModel.removeTopCard();
        setState(() {
          _position = Offset.zero;
        });
        _animController.reset();
      }
    });

    // Carrega os dados reais do banco ao abrir
    _viewModel.loadCards();
    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

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
            // 1. Alternador de Modo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SegmentedButton<SwipeMode>(
                    segments: const [
                      ButtonSegment<SwipeMode>(
                        value: SwipeMode.player,
                        label: Text('Jogador'),
                        icon: Icon(Icons.person, size: 18),
                      ),
                      ButtonSegment<SwipeMode>(
                        value: SwipeMode.master,
                        label: Text('Mestre'),
                        icon: Icon(Icons.shield, size: 18),
                      ),
                    ],
                    selected: {_viewModel.mode},
                    onSelectionChanged: (newSelection) {
                      _viewModel.setMode(newSelection.first);
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

            // 2. Pilha de Cards de Match
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _viewModel.cards.isEmpty
                        ? _buildEmptyState(theme)
                        : Stack(
                            children: _viewModel.cards.asMap().entries.map((entry) {
                              final index = entry.key;
                              final cardData = entry.value;

                              if (index == _viewModel.cards.length - 1) {
                                return _buildTopCard(cardData, theme);
                              }

                              return _buildBackgroundCard(cardData, theme);
                            }).toList(),
                          ),
              ),
            ),

            // 3. Botões Flutuantes
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'pass_btn',
                    onPressed: _viewModel.cards.isEmpty || _animController.isAnimating ? null : _swipeLeft,
                    backgroundColor: theme.colorScheme.surface,
                    child: Icon(Icons.close, color: theme.colorScheme.error, size: 24),
                  ),
                  FloatingActionButton.small(
                    heroTag: 'info_btn',
                    onPressed: _viewModel.cards.isEmpty ? null : () {},
                    backgroundColor: theme.colorScheme.surface,
                    child: Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 24),
                  ),
                  FloatingActionButton(
                    heroTag: 'match_btn',
                    onPressed: _viewModel.cards.isEmpty || _animController.isAnimating ? null : _swipeRight,
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

  Widget _buildTopCard(SwipeItemModel cardData, ThemeData theme) {
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
              onPanStart: (_) => setState(() => _isDragging = true),
              onPanUpdate: (details) {
                setState(() {
                  _position += details.delta;
                });
              },
              onPanEnd: (_) {
                setState(() => _isDragging = false);
                final threshold = _screenSize.width * 0.35;

                if (_position.dx > threshold) {
                  _swipeRight();
                } else if (_position.dx < -threshold) {
                  _swipeLeft();
                } else {
                  setState(() => _position = Offset.zero);
                }
              },
              child: Stack(
                children: [
                  _buildCardContent(cardData, theme),
                  if (_position.dx != 0 && !_animController.isAnimating) _buildSwipeOverlay(theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundCard(SwipeItemModel cardData, ThemeData theme) {
    return Transform.scale(
      scale: 0.95,
      child: _buildCardContent(cardData, theme),
    );
  }

  Widget _buildCardContent(SwipeItemModel cardData, ThemeData theme) {
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
            Positioned.fill(
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    _viewModel.mode == SwipeMode.player ? Icons.castle_outlined : Icons.person_outline,
                    size: 80,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
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
                          cardData.title,
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
                          cardData.system,
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
                        cardData.location,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cardData.desc,
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
                color: isRight ? const Color.fromARGB(255, 236, 202, 7) : theme.colorScheme.error,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withValues(alpha: 0.3),
            ),
            child: Text(
              isRight ? 'ACEITAR' : 'PASSAR',
              style: TextStyle(
                color: isRight ? const Color.fromARGB(255, 236, 202, 7) : theme.colorScheme.error,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

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
            'Tente mudar o modo no topo ou atualizar a busca.',
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