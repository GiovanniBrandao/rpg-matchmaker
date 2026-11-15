// lib/features/profile/view/profile_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_rpg/features/auth/service/auth_service.dart';
import 'package:app_rpg/features/welcome/view/welcome_view.dart';
import '../model/character_model.dart';
import '../model/master_model.dart';
import '../model/user_profile_model.dart';
import '../viewmodel/profile_viewmodel.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileViewModel _viewModel = ProfileViewModel();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _viewModel.profile.userName);
    _emailController = TextEditingController(text: _viewModel.profile.email);

    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (!mounted) return;

    if (_viewModel.profile.userName.isNotEmpty &&
        _nameController.text != _viewModel.profile.userName) {
      _nameController.text = _viewModel.profile.userName;
    }
    if (_viewModel.profile.email.isNotEmpty &&
        _emailController.text != _viewModel.profile.email) {
      _emailController.text = _viewModel.profile.email;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _nameController.dispose();
    _emailController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  // ================= WIDGET AUXILIAR: RENDERIZADOR DE IMAGEM COM TEMA =================
  Widget _buildLocalImage(
    BuildContext context,
    String? imagePath, {
    double? width,
    double? height,
    IconData placeholderIcon = Icons.image,
  }) {
    final theme = Theme.of(context);
    final bgColor = theme.colorScheme.surfaceContainerHighest;
    final iconColor = theme.colorScheme.onSurfaceVariant;

    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: bgColor,
        child: Icon(placeholderIcon, size: 40, color: iconColor),
      );
    }

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: width,
          height: height,
          color: bgColor,
          child: Icon(Icons.broken_image, size: 32, color: iconColor),
        ),
      );
    }

    return Image.file(
      File(imagePath),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: width,
        height: height,
        color: bgColor,
        child: Icon(Icons.broken_image, size: 32, color: iconColor),
      ),
    );
  }

  // ================= DIÁLOGOS DE CONFIRMAÇÃO DE DELEÇÃO =================
  void _confirmDeleteCampaign(BuildContext modalCtx, String campaignId) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Excluir Campanha'),
        content: const Text(
            'Tem certeza de que deseja excluir esta campanha? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              Navigator.pop(modalCtx);
              await _viewModel.deleteCampaign(campaignId);
            },
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCharacter(BuildContext modalCtx, String characterId) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Excluir Personagem'),
        content: const Text(
            'Tem certeza de que deseja excluir esta ficha de personagem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              Navigator.pop(modalCtx);
              await _viewModel.deleteCharacter(characterId);
            },
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );
  }

  // ================= MODAL: CRIAR / EDITAR CAMPANHA (MESTRE) =================
  void _openCampaignModal({MasterModel? campaign}) {
    final isEditing = campaign != null;
    final nameCtrl = TextEditingController(text: campaign?.name ?? '');
    final descCtrl = TextEditingController(text: campaign?.description ?? '');
    String selectedSystem =
        campaign?.system ?? _viewModel.availableSystems.first;
    bool isOnline = campaign?.isOnline ?? true;

    String? selectedImagePath = campaign?.imagePath;
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            Future<void> pickImage(ImageSource source) async {
              final XFile? image = await picker.pickImage(
                source: source,
                maxWidth: 1000,
                maxHeight: 1000,
                imageQuality: 85,
              );
              if (image != null) {
                setModalState(() {
                  selectedImagePath = image.path;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                top: 20,
                left: 16,
                right: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Editar Campanha' : 'Criar Nova Campanha',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (isEditing)
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: Theme.of(context).colorScheme.error),
                            tooltip: 'Excluir Campanha',
                            onPressed: () =>
                                _confirmDeleteCampaign(ctx, campaign.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _buildLocalImage(
                              context,
                              selectedImagePath,
                              width: 120,
                              height: 150,
                              placeholderIcon: Icons.castle_outlined,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Galeria'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () => pickImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Câmera'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Nome da Campanha'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedSystem,
                      decoration:
                          const InputDecoration(labelText: 'Sistema de RPG'),
                      items: _viewModel.availableSystems.map((system) {
                        return DropdownMenuItem(
                          value: system,
                          child: Text(system),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedSystem = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Mesa Online'),
                      subtitle: Text(
                          isOnline ? 'Mesa Online' : 'Mesa Presencial'),
                      value: isOnline,
                      onChanged: (val) => setModalState(() => isOnline = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          labelText: 'Descrição / Resumo da Campanha'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        final newCamp = MasterModel(
                          id: campaign?.id ?? '',
                          masterId: campaign?.masterId ?? '',
                          masterName: campaign?.masterName ?? '',
                          name: nameCtrl.text,
                          system: selectedSystem,
                          description: descCtrl.text,
                          isOnline: isOnline,
                          imagePath: selectedImagePath,
                        );

                        if (isEditing) {
                          _viewModel.updateCampaign(newCamp);
                        } else {
                          _viewModel.addCampaign(newCamp);
                        }
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      icon: const Icon(Icons.check),
                      label: Text(
                          isEditing ? 'SALVAR CAMPANHA' : 'CRIAR CAMPANHA'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= MODAL: CRIAR / EDITAR PERSONAGEM =================
  void _openCharacterModal({CharacterModel? character}) {
    final isEditing = character != null;
    final nameCtrl = TextEditingController(text: character?.name ?? '');
    final classCtrl =
        TextEditingController(text: character?.characterClass ?? '');
    final bioCtrl = TextEditingController(text: character?.bio ?? '');
    String selectedSystem =
        character?.system ?? _viewModel.availableSystems.first;

    String? selectedImagePath = character?.imagePath;
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            Future<void> pickImage(ImageSource source) async {
              final XFile? image = await picker.pickImage(
                source: source,
                maxWidth: 1000,
                maxHeight: 1000,
                imageQuality: 85,
              );
              if (image != null) {
                setModalState(() {
                  selectedImagePath = image.path;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                top: 20,
                left: 16,
                right: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Editar Personagem' : 'Criar Novo Personagem',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (isEditing)
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: Theme.of(context).colorScheme.error),
                            tooltip: 'Excluir Personagem',
                            onPressed: () =>
                                _confirmDeleteCharacter(ctx, character.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _buildLocalImage(
                              context,
                              selectedImagePath,
                              width: 120,
                              height: 150,
                              placeholderIcon: Icons.person,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Galeria'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () => pickImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Câmera'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Nome do Personagem'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedSystem,
                      decoration:
                          const InputDecoration(labelText: 'Sistema de RPG'),
                      items: _viewModel.availableSystems.map((system) {
                        return DropdownMenuItem(
                          value: system,
                          child: Text(system),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedSystem = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: classCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Classe / Nível'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: bioCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          labelText: 'Descrição / História'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        final newChar = CharacterModel(
                          id: character?.id ?? '',
                          playerId: character?.playerId ?? '',
                          playerName: character?.playerName ?? '',
                          name: nameCtrl.text,
                          characterClass: classCtrl.text,
                          system: selectedSystem,
                          bio: bioCtrl.text,
                          imagePath: selectedImagePath,
                        );

                        if (isEditing) {
                          _viewModel.updateCharacter(newChar);
                        } else {
                          _viewModel.addCharacter(newChar);
                        }
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50)),
                      icon: const Icon(Icons.check),
                      label: Text(isEditing ? 'SALVAR FICHA' : 'CRIAR FICHA'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = _viewModel.profile;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seu Perfil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair da conta',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _viewModel.refreshData();
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CAMPO: NOME DO USUÁRIO
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Nome ou Nickname',
                      labelStyle:
                          TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      floatingLabelStyle: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    onFieldSubmitted: (val) {
                      _viewModel.saveUserData(
                          name: val, email: _emailController.text);
                    },
                  ),
                  const SizedBox(height: 16),

                  // CAMPO: E-MAIL
                  TextFormField(
                    controller: _emailController,
                    readOnly: true,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      labelStyle:
                          TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      floatingLabelStyle: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ALTERNADOR: MESTRE OU JOGADOR
                  SwitchListTile(
                    title: const Text('Sou Mestre de RPG'),
                    subtitle:
                        const Text('Habilita a criação de mesas e campanhas'),
                    value: profile.isGameMaster,
                    onChanged: (val) => _viewModel.toggleIsGameMaster(val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),

                  // DROPDOWN: PROFICIÊNCIA (Usando 'value' para reatividade correta)
                  DropdownButtonFormField<ProficiencyLevel>(
                    value: profile.proficiency,
                    decoration: InputDecoration(
                      labelText: 'Nível de Experiência',
                      labelStyle:
                          TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      floatingLabelStyle: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: const Icon(Icons.casino_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    items: ProficiencyLevel.values.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(level.label),
                      );
                    }).toList(),
                    onChanged: (val) => _viewModel.setProficiency(val),
                  ),
                  const SizedBox(height: 20),

                  // SEÇÃO: SISTEMAS DE AFINIDADE
                  Text(
                    'Sistemas com Afinidade:',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: _viewModel.availableSystems.map((system) {
                      final isSelected =
                          profile.favoriteSystems.contains(system);
                      return FilterChip(
                        label: Text(system),
                        selected: isSelected,
                        onSelected: (_) => _viewModel.toggleSystem(system),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // SEÇÃO: CAMPANHAS / MESAS (Visível apenas para Mestres)
                  if (profile.isGameMaster) ...[
                    _buildSectionHeader(
                        'Minhas Campanhas', Icons.castle_outlined),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: profile.campaigns.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildAddCampaignCard();
                          }
                          return _buildCampaignCard(
                              profile.campaigns[index - 1]);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // SEÇÃO: PERSONAGENS / FICHAS (Visível para todos)
                  _buildSectionHeader('Meus Personagens', Icons.person_outline),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: profile.characters.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildAddCharacterCard();
                        }
                        return _buildCharacterCard(
                            profile.characters[index - 1]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da Conta'),
        content: const Text('Deseja realmente encerrar a sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().signOut();

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeView()),
                  (route) => false,
                );
              }
            },
            child: const Text('SAIR'),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(MasterModel campaign) {
    final theme = Theme.of(context);

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => _openCampaignModal(campaign: campaign),
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: _buildLocalImage(
                  context,
                  campaign.imagePath,
                  placeholderIcon: Icons.castle_outlined,
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
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      campaign.system,
                      style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterCard(CharacterModel character) {
    final theme = Theme.of(context);

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => _openCharacterModal(character: character),
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: _buildLocalImage(
                  context,
                  character.imagePath,
                  placeholderIcon: Icons.person,
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
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      character.characterClass,
                      style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddCampaignCard() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => _openCampaignModal(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryColor, width: 2),
            color: primaryColor.withValues(alpha: 0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, size: 36, color: primaryColor),
              const SizedBox(height: 8),
              Text(
                'Nova Campanha',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddCharacterCard() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => _openCharacterModal(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryColor, width: 2),
            color: primaryColor.withValues(alpha: 0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, size: 36, color: primaryColor),
              const SizedBox(height: 8),
              Text(
                'Nova Ficha',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}