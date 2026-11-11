// lib/features/chat/view/chat_list_view.dart
import 'package:flutter/material.dart';
import '../model/chat_models.dart';
import '../service/chat_service.dart';
import 'chat_room_view.dart';

/// Lista de conversas (mesas) das quais o usuário participa.
class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  final _service = ChatService();
  late final Stream<List<ChatRoom>> _rooms = _service.watchMyRooms();

  Future<void> _createRoom() async {
    final titleCtrl = TextEditingController();
    String system = 'D&D 5e';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Nova sala de chat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nome da mesa / sala'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: system,
                decoration: const InputDecoration(labelText: 'Sistema'),
                items: const [
                  'D&D 5e', 'Tormenta20', 'Call of Cthulhu',
                  'Pathfinder 2e', 'Vampiro: A Máscara', 'Ordem Paranormal',
                ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setLocal(() => system = v ?? system),
              ),
              const SizedBox(height: 8),
              const Text(
                'Quem criar ou entrar numa sala com o mesmo nome conversa junto.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Criar / Entrar')),
          ],
        ),
      ),
    );
    final title = titleCtrl.text.trim();
    if (ok != true || title.isEmpty) return;

    try {
      final id = await _service.joinOrCreateRoom(title: title, system: system);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatRoomView(roomId: id, title: title, system: system)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ChatService.friendlyError(e))),
      );
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '${two(dt.hour)}:${two(dt.minute)}';
    }
    return '${two(dt.day)}/${two(dt.month)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Conversas'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createRoom,
        icon: const Icon(Icons.add_comment),
        label: const Text('Nova sala'),
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: _rooms,
        builder: (context, snap) {
          if (snap.hasError) {
            return _message(theme, Icons.error_outline, ChatService.friendlyError(snap.error!));
          }
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final rooms = snap.data!;
          if (rooms.isEmpty) {
            return _message(
              theme,
              Icons.forum_outlined,
              'Nenhuma conversa ainda.\n\nDeslize para a direita em uma mesa na aba '
              '"Encontrar" ou toque em "Nova sala" para começar a conversar.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: rooms.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final r = rooms[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    r.title.isNotEmpty ? r.title[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  r.lastMessage.isNotEmpty
                      ? r.lastMessage
                      : '${r.system} • ${r.members.length} participante(s)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(_formatTime(r.lastMessageAt), style: theme.textTheme.bodySmall),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatRoomView(roomId: r.id, title: r.title, system: r.system),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _message(ThemeData theme, IconData icon, String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(text, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
