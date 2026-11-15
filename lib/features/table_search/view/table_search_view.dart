// lib/features/table_search/view/table_search_view.dart
import 'dart:io';
import 'package:flutter/material.dart';

// ✅ Importações dos Models e da ViewModel (sem importar o Service diretamente aqui)
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
  // ✅ Instancia a ViewModel para gerenciar o estado da View
  final TableSearchViewModel _viewModel = TableSearchViewModel();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Define o modo inicial com base no papel do usuário
    final initialMode = widget.isGameMaster ? SearchMode.characters : SearchMode.tables;
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
        color: Colors.grey.shade800,
        child: Icon(placeholderIcon, size: 48, color: Colors.white54),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _viewModel.mode == SearchMode.tables ? 'Buscar Mesas' : 'Buscar Personagens',
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Alternador entre Mesas e Personagens
          Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 16.0, right: 16.0),
            child: SegmentedButton<SearchMode>(
              segments: const [
                ButtonSegment(
                  value: SearchMode.tables,
                  label: Text('Mesas'),
                  icon: Icon(Icons.castle_outlined),
                ),
                ButtonSegment(
                  value: SearchMode.characters,
                  label: Text('Personagens'),
                  icon: Icon(Icons.person_outline),
                ),
              ],
              selected: {_viewModel.mode},
              onSelectionChanged: (newSelection) {
                _viewModel.setSearchMode(newSelection.first);
              },
            ),
          ),

          // Campo de busca com debounce/filtro reativo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _viewModel.search,
              decoration: InputDecoration(
                hintText: _viewModel.mode == SearchMode.tables
                    ? 'Buscar por campanha, sistema ou mestre...'
                    : 'Buscar por nome, classe, história ou jogador...',
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Renderização dinâmica dos resultados
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
    final isTables = _viewModel.mode == SearchMode.tables;
    final isEmpty = isTables ? _viewModel.campaigns.isEmpty : _viewModel.characters.isEmpty;

    return RefreshIndicator(
      onRefresh: _viewModel.loadData,
      child: isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                Center(
                  child: Text(
                    isTables ? 'Nenhuma mesa encontrada.' : 'Nenhum personagem encontrado.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: isTables ? _viewModel.campaigns.length : _viewModel.characters.length,
              itemBuilder: (context, index) {
                return isTables
                    ? _buildCampaignCard(_viewModel.campaigns[index])
                    : _buildCharacterCard(_viewModel.characters[index]);
              },
            ),
    );
  }

  Widget _buildCampaignCard(CampaignSearchModel item) {
    final theme = Theme.of(context);
    final campaign = item.campaign;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 130,
            width: double.infinity,
            child: _buildImage(campaign.imagePath, Icons.castle_outlined),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        campaign.name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Chip(
                      label: Text(campaign.system, style: const TextStyle(fontSize: 10)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                Text(
                  'Mestre: ${item.masterName}',
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
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 130,
            width: double.infinity,
            child: _buildImage(character.imagePath, Icons.person),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        character.name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Chip(
                      label: Text(character.characterClass, style: const TextStyle(fontSize: 10)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                Text(
                  'Jogador: ${item.playerName} • Exp: ${item.proficiency.label}',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}