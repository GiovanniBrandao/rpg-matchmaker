// lib/features/swipe/view/swipe_view.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../chat/service/chat_service.dart';
import '../../chat/view/chat_list_view.dart';
import '../../chat/view/chat_room_view.dart';
import '../../dice/view/dice_view.dart';
import '../../locations/model/rpg_location_model.dart';
import '../model/swipe_model.dart';
import '../viewmodel/swipe_viewmodel.dart';

class SwipeView extends StatefulWidget {
  const SwipeView({super.key});

  @override
  State<SwipeView> createState() => _SwipeViewState();
}

class _SwipeViewState extends State<SwipeView> with SingleTickerProviderStateMixin {
  final SwipeViewModel _viewModel = SwipeViewModel();
  final ChatService _chatService = ChatService();

  Offset _position = Offset.zero;
  Size _screenSize = Size.zero;

  late AnimationController _animController;
  late Animation<Offset> _swipeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
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
    HapticFeedback.lightImpact();
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
        duration: const Duration(milliseconds: 900),
        backgroundColor: theme.colorScheme.error,
      ),
    );
  }

  void _swipeRight() {
    HapticFeedback.mediumImpact();
    final theme = Theme.of(context);
    final card = _viewModel.cards.isNotEmpty ? _viewModel.cards.last : null;
    _swipeAnimation = Tween<Offset>(
      begin: _position,
      end: Offset(_screenSize.width * 2, _position.dy),
    ).animate(_animController);

    _animController.forward();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Match confirmado! Sala de chat liberada.'),
        duration: const Duration(seconds: 3),
        backgroundColor: theme.colorScheme.primary,
        action: card == null
            ? null
            : SnackBarAction(
                label: 'ABRIR CHAT',
                textColor: Colors.white,
                onPressed: () => _openChatFor(card),
              ),
      ),
    );

    if (card != null) {
      _chatService.joinOrCreateRoom(
        title: card.title,
        system: card.system,
        description: card.desc,
      );
    }
  }

  Future<void> _openChatFor(SwipeItemModel card) async {
    final id = await _chatService.joinOrCreateRoom(
      title: card.title,
      system: card.system,
      description: card.desc,
    );
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomView(roomId: id, title: card.title, system: card.system),
      ),
    );
  }

  /// Abre modal com ficha completa da mesa/jogador e locais sugeridos para jogar (IHC).
  void _showCardDetailsModal(SwipeItemModel card) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      card.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(
                      card.system,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(child: Text(card.location, style: theme.textTheme.bodyMedium)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.schedule, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(child: Text(card.schedule, style: theme.textTheme.bodyMedium)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.storefront, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Local sugerido: ${card.suggestedVenue}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                'Sobre a Aventura / Perfil',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(card.desc, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              Text(
                'Locais Parceiros Próximos para esta Sessão:',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 86,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: RpgLocationModel.catalog.length,
                  itemBuilder: (_, i) {
                    final loc = RpgLocationModel.catalog[i];
                    return Container(
                      width: 230,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(loc.icon, color: theme.colorScheme.primary, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  loc.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  loc.distanceKm == 0
                                      ? loc.city
                                      : '${loc.city} (${loc.distanceKm} km)',
                                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  loc.priceInfo,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: theme.colorScheme.primary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openChatFor(card);
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Abrir Chat'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _swipeRight();
                      },
                      icon: const Icon(Icons.casino),
                      label: const Text('Dar Match!'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
            // 1. Barra Superior: Alternador de Modo e Botão de Conversas com Badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SegmentedButton<SwipeMode>(
                    segments: const [
                      ButtonSegment<SwipeMode>(
                        value: SwipeMode.player,
                        label: Text('Mesas'),
                        icon: Icon(Icons.castle_outlined, size: 18),
                      ),
                      ButtonSegment<SwipeMode>(
                        value: SwipeMode.master,
                        label: Text('Jogadores'),
                        icon: Icon(Icons.person_search_outlined, size: 18),
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Mesa de Dados',
                        icon: const Icon(Icons.casino_outlined, size: 20),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DiceRollView()),
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ChatListView()),
                          );
                        },
                        icon: const Icon(Icons.forum_outlined, size: 18),
                        label: const Text('Chats'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Pilha de Cards de Match
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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

            // 3. Botões Flutuantes com rótulos claros (IHC: Affordance e Lei de Fitts)
            Padding(
              padding: const EdgeInsets.only(bottom: 14.0, top: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'pass_btn',
                    tooltip: 'Passar oportunidade',
                    onPressed: _viewModel.cards.isEmpty || _animController.isAnimating
                        ? null
                        : _swipeLeft,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.close, color: theme.colorScheme.error, size: 24),
                  ),
                  FloatingActionButton.small(
                    heroTag: 'info_btn',
                    tooltip: 'Ver ficha completa e locais',
                    onPressed: _viewModel.cards.isEmpty
                        ? null
                        : () => _showCardDetailsModal(_viewModel.cards.last),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 24),
                  ),
                  FloatingActionButton.extended(
                    heroTag: 'match_btn',
                    onPressed: _viewModel.cards.isEmpty || _animController.isAnimating
                        ? null
                        : _swipeRight,
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    icon: const Icon(Icons.casino),
                    label: const Text(
                      'QUERO JOGAR',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
        final currentOffset =
            _animController.isAnimating ? _swipeAnimation.value : _position;

        return Transform.translate(
          offset: currentOffset,
          child: Transform.rotate(
            angle: _animController.isAnimating ? angle * 2 : angle,
            child: GestureDetector(
              onTap: () => _showCardDetailsModal(cardData),
              onPanUpdate: (details) {
                setState(() {
                  _position += details.delta;
                });
              },
              onPanEnd: (_) {
                final threshold = _screenSize.width * 0.30;

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
                  if (_position.dx != 0 && !_animController.isAnimating)
                    _buildSwipeOverlay(theme),
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
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Fundo estilizado temático
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF4A2C0A),
                      theme.colorScheme.surfaceContainerHighest,
                      const Color(0xFF1A1612),
                    ],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 110),
                    child: Icon(
                      _viewModel.mode == SwipeMode.player
                          ? Icons.castle_outlined
                          : Icons.shield_outlined,
                      size: 96,
                      color: const Color(0xFFFFD700).withValues(alpha: 0.28),
                    ),
                  ),
                ),
              ),
            ),
            // Badge superior de Local Sugerido
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.storefront, color: Color(0xFFFFD700), size: 15),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              cardData.suggestedVenue,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                      Colors.black.withValues(alpha: 0.90),
                    ],
                    stops: const [0.35, 1.0],
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
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          cardData.system,
                          style: const TextStyle(
                            color: Color(0xFF261900),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFFFFD700), size: 15),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${cardData.location} • ${cardData.schedule}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cardData.desc,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.3),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Toque no card para ver local, horários e detalhes',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
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
      top: 56,
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
                color: isRight
                    ? const Color.fromARGB(255, 236, 202, 7)
                    : theme.colorScheme.error,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withValues(alpha: 0.45),
            ),
            child: Text(
              isRight ? 'QUERO JOGAR' : 'PASSAR',
              style: TextStyle(
                color: isRight
                    ? const Color.fromARGB(255, 236, 202, 7)
                    : theme.colorScheme.error,
                fontSize: 22,
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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_off_outlined,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Você viu todas as oportunidades!',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recarregue a pilha de cards ou alterne entre Mesas e Jogadores no topo.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _viewModel.loadCards,
              icon: const Icon(Icons.refresh),
              label: const Text('Recarregar Oportunidades'),
            ),
          ],
        ),
      ),
    );
  }
}
