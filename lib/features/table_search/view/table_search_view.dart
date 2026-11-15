// lib/features/table_search/view/table_search_view.dart
import 'dart:io';
import 'package:flutter/material.dart';

import '../../chat/service/chat_service.dart';
import '../../chat/view/chat_room_view.dart';
import '../../locations/model/rpg_location_model.dart';
import '../model/campaign_search_model.dart';
import '../model/character_search_model.dart';
import '../viewmodel/table_search_viewmodel.dart';

class TableSearchView extends StatefulWidget {
  final bool isGameMaster;

  const TableSearchView({
    super.key,
    this.isGameMaster = false,
  });

  @override
  State<TableSearchView> createState() => _TableSearchViewState();
}

class _TableSearchViewState extends State<TableSearchView> {
  final TableSearchViewModel _viewModel = TableSearchViewModel();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initialMode =
        widget.isGameMaster ? SearchMode.characters : SearchMode.tables;
    _viewModel.setSearchMode(initialMode);

    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Widget _buildImage(String? imagePath, IconData placeholderIcon) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A2C0A), Color(0xFF231D16)],
          ),
        ),
        child: Icon(placeholderIcon, size: 48, color: const Color(0xFFFFD700)),
      );
    }

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: Colors.grey.shade800,
          child: const Icon(Icons.broken_image, size: 48, color: Colors.white54),
        ),
      );
    }

    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: Colors.grey.shade800,
        child: const Icon(Icons.broken_image, size: 48, color: Colors.white54),
      ),
    );
  }

  String get _title => switch (_viewModel.mode) {
        SearchMode.tables => 'Explorar Mesas',
        SearchMode.characters => 'Explorar Personagens',
        SearchMode.locations => 'Locais para Jogar RPG',
      };

  String get _hint => switch (_viewModel.mode) {
        SearchMode.tables => 'Buscar por campanha, sistema ou mestre...',
        SearchMode.characters => 'Buscar por nome, classe ou jogador...',
        SearchMode.locations => 'Buscar por cidade, taverna, loja ou sistema...',
      };

  Future<void> _openRoom({
    required String title,
    required String system,
    required String description,
  }) async {
    final chat = ChatService();
    try {
      final id = await chat.joinOrCreateRoom(
        title: title,
        system: system,
        description: description,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomView(roomId: id, title: title, system: system),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ChatService.friendlyError(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Alternador entre Mesas, Personagens e Locais de RPG
          Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<SearchMode>(
                segments: const [
                  ButtonSegment(
                    value: SearchMode.tables,
                    label: Text('Mesas'),
                    icon: Icon(Icons.castle_outlined, size: 18),
                  ),
                  ButtonSegment(
                    value: SearchMode.characters,
                    label: Text('Heróis'),
                    icon: Icon(Icons.person_outline, size: 18),
                  ),
                  ButtonSegment(
                    value: SearchMode.locations,
                    label: Text('Locais'),
                    icon: Icon(Icons.place_outlined, size: 18),
                  ),
                ],
                selected: {_viewModel.mode},
                onSelectionChanged: (newSelection) {
                  _searchController.clear();
                  _viewModel.setSearchMode(newSelection.first);
                },
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
              ),
            ),
          ),

          // Campo de busca com filtro reativo
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: TextField(
              controller: _searchController,
              onChanged: _viewModel.search,
              decoration: InputDecoration(
                hintText: _hint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _viewModel.search('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          Expanded(
            child: _viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildResultList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildResultList(ThemeData theme) {
    switch (_viewModel.mode) {
      case SearchMode.tables:
        if (_viewModel.campaigns.isEmpty) {
          return const Center(child: Text('Nenhuma mesa encontrada.'));
        }
        return RefreshIndicator(
          onRefresh: _viewModel.loadData,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _viewModel.campaigns.length,
            itemBuilder: (_, index) =>
                _buildCampaignCard(_viewModel.campaigns[index]),
          ),
        );
      case SearchMode.characters:
        if (_viewModel.characters.isEmpty) {
          return const Center(child: Text('Nenhum personagem encontrado.'));
        }
        return RefreshIndicator(
          onRefresh: _viewModel.loadData,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _viewModel.characters.length,
            itemBuilder: (_, index) =>
                _buildCharacterCard(_viewModel.characters[index]),
          ),
        );
      case SearchMode.locations:
        if (_viewModel.locations.isEmpty) {
          return const Center(child: Text('Nenhum local encontrado.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _viewModel.locations.length,
          itemBuilder: (_, index) =>
              _buildLocationCard(_viewModel.locations[index]),
        );
    }
  }

  Widget _buildCampaignCard(CampaignSearchModel item) {
    final theme = Theme.of(context);
    final campaign = item.campaign;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 110,
            width: double.infinity,
            child: _buildImage(campaign.imagePath, Icons.castle_outlined),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        campaign.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(campaign.system,
                          style: const TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                Text(
                  'Mestre: ${item.masterName} • ${campaign.isOnline ? "Online / Híbrido" : "Presencial"}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (campaign.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    campaign.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: () => _openRoom(
                      title: campaign.name,
                      system: campaign.system,
                      description: campaign.description,
                    ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Entrar no Chat da Mesa'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCard(CharacterSearchModel item) {
    final theme = Theme.of(context);
    final character = item.character;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100,
            width: double.infinity,
            child: _buildImage(character.imagePath, Icons.person),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        character.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Chip(
                      label: Text(character.characterClass,
                          style: const TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                Text(
                  'Jogador: ${item.playerName} • Exp: ${item.proficiency.label} • ${character.system}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (character.bio.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    character.bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: () => _openRoom(
                      title: 'Convite • ${character.name}',
                      system: character.system,
                      description: 'Conversa com ${item.playerName}',
                    ),
                    icon: const Icon(Icons.forum_outlined, size: 18),
                    label: const Text('Convidar para Mesa'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(RpgLocationModel loc) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(loc.icon, color: theme.colorScheme.primary, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (loc.isPartner) ...[
                            const Icon(Icons.verified, size: 15, color: Colors.amber),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              loc.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.star, size: 15, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            '${loc.rating}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        '${loc.type} • ${loc.distanceKm == 0 ? loc.city : "${loc.city} (${loc.distanceKm} km)"}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(loc.address, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(loc.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${loc.openingHours} • ${loc.priceInfo}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final a in loc.amenities.take(3))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(a, style: const TextStyle(fontSize: 11)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Sistemas: ${loc.popularSystems.join(", ")}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: () => _openRoom(
                    title: 'Ponto de Encontro • ${loc.name}',
                    system: loc.popularSystems.first,
                    description: '${loc.address} (${loc.openingHours})',
                  ),
                  icon: const Icon(Icons.groups_outlined, size: 18),
                  label: const Text('Marcar Mesa Aqui'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
