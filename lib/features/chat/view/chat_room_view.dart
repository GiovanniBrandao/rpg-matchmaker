// lib/features/chat/view/chat_room_view.dart
import 'package:flutter/material.dart';
import '../../../core/widgets/rich_message_text.dart';
import '../../assistant/service/ai_game_master_service.dart';
import '../../dice/view/dice_view.dart';
import '../model/chat_models.dart';
import '../service/chat_service.dart';

/// Sala de chat em grupo de uma mesa, com o "Mestre IA" disponível para ajudar.
///
/// - Botão ✨ pede à IA uma dica/próximo passo com base na conversa recente.
/// - Mensagens que começam com "/ia" são respondidas pela IA na própria sala.
class ChatRoomView extends StatefulWidget {
  const ChatRoomView({
    super.key,
    required this.roomId,
    required this.title,
    this.system = '',
  });

  final String roomId;
  final String title;
  final String system;

  @override
  State<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> {
  final _service = ChatService();
  final _ai = AiGameMasterService();
  final _input = TextEditingController();
  late final Stream<List<ChatMessage>> _messages = _service.watchMessages(widget.roomId);

  List<ChatMessage> _latest = const [];
  bool _aiThinking = false;

  String get _system => widget.system.isEmpty ? 'D&D 5e' : widget.system;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ChatService.friendlyError(e))),
    );
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    try {
      await _service.sendMessage(widget.roomId, text);
      if (text.toLowerCase().startsWith('/ia')) {
        final question = text.substring(3).trim();
        await _askAi(question.isEmpty ? null : question);
      }
    } catch (e) {
      _showError(e);
    }
  }

  /// Monta o contexto com as últimas mensagens e pede ajuda à IA.
  Future<void> _askAi([String? question]) async {
    if (_aiThinking) return;
    setState(() => _aiThinking = true);
    try {
      final history = _latest.take(15).toList().reversed
          .where((m) => m.type != ChatMessageType.system)
          .map((m) => '${m.senderName}: ${m.text}')
          .join('\n');
      final prompt = StringBuffer()
        ..writeln('Você está ajudando o grupo de RPG da mesa "${widget.title}" ($_system).')
        ..writeln('Conversa recente do grupo:')
        ..writeln(history.isEmpty ? '(sem mensagens ainda)' : history)
        ..writeln()
        ..writeln(question != null
            ? 'Pergunta do jogador: $question'
            : 'Dê uma dica útil para o grupo agora: sugira o próximo passo da '
                'aventura ou da organização da mesa, com 2 ou 3 opções do que podem fazer.');
      final answer = await _ai.ask(prompt.toString(), system: _system);
      await _service.sendMessage(widget.roomId, answer, type: ChatMessageType.ai);
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _aiThinking = false);
    }
  }

  Future<void> _leave() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da mesa?'),
        content: const Text('Você deixará de receber as mensagens desta sala.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sair')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service.leaveRoom(widget.roomId);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (widget.system.isNotEmpty)
              Text(widget.system, style: theme.textTheme.bodySmall),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Mesa de Dados',
            icon: const Icon(Icons.casino_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DiceRollView()),
              );
            },
          ),
          IconButton(
            tooltip: 'Pedir dica ao Mestre IA',
            icon: const Icon(Icons.auto_awesome),
            onPressed: _aiThinking ? null : () => _askAi(),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => v == 'leave' ? _leave() : null,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'leave', child: Text('Sair da mesa')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: _messages,
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(ChatService.friendlyError(snap.error!),
                            textAlign: TextAlign.center),
                      ),
                    );
                  }
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  _latest = snap.data!;
                  if (_latest.isEmpty) {
                    return const Center(
                      child: Text('Diga olá para a mesa! 👋\nDica: escreva "/ia" + pergunta para chamar o Mestre IA.',
                          textAlign: TextAlign.center),
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: _latest.length,
                    itemBuilder: (_, i) => _buildMessage(_latest[i], theme),
                  );
                },
              ),
            ),
            if (_aiThinking)
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text('✨ Mestre IA está pensando…',
                    style: TextStyle(fontStyle: FontStyle.italic)),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Mensagem (use /ia para chamar a IA)',
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
                    icon: const Icon(Icons.send),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage m, ThemeData theme) {
    if (m.type == ChatMessageType.system) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
          child: Text(m.text,
              style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
        ),
      );
    }

    final isMine = m.type == ChatMessageType.user && m.senderId == _service.currentUid;
    final isAi = m.type == ChatMessageType.ai;
    final bg = isMine
        ? theme.colorScheme.primary
        : isAi
            ? const Color(0xFFFFF3D6)
            : Colors.white;
    final fg = isMine ? Colors.white : Colors.black87;
    final hh = m.createdAt.hour.toString().padLeft(2, '0');
    final mm = m.createdAt.minute.toString().padLeft(2, '0');

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: isAi ? Border.all(color: theme.colorScheme.secondary, width: 1.5) : null,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMine)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isAi) ...[
                    Icon(Icons.auto_awesome, size: 14, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                  ],
                  Text(m.senderName,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary)),
                ],
              ),
            RichMessageText(m.text, style: TextStyle(color: fg, fontSize: 15, height: 1.3)),
            const SizedBox(height: 2),
            Text('$hh:$mm',
                style: TextStyle(fontSize: 10, color: fg.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}
