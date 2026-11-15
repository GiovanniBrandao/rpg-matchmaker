import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_rpg/main.dart';
import 'package:app_rpg/features/assistant/service/offline_game_master.dart';
import 'package:app_rpg/features/assistant/view/assistant_view.dart';
import 'package:app_rpg/features/chat/service/chat_service.dart';
import 'package:app_rpg/features/marketplace/view/marketplace_view.dart';
import 'package:app_rpg/features/table_search/view/table_search_view.dart';

void main() {
  testWidgets('Tela de boas-vindas é exibida com acesso rápido', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('RPG Matchmaker'), findsOneWidget);
    expect(find.text('ENTRAR / CADASTRAR'), findsOneWidget);
    expect(find.text('ACESSO RÁPIDO (MODO TESTE)'), findsOneWidget);
  });

  group('OfflineGameMaster', () {
    final gm = OfflineGameMaster(random: Random(42));

    test('interpreta rolagens de dados', () {
      expect(gm.reply('🎲 Rolei 1d20 e tirei 20.'), contains('crítico'));
      expect(gm.reply('rolei 1'), contains('Falha crítica'));
      expect(gm.reply('tirei 16'), contains('Sucesso'));
    });

    test('responde pedidos por palavra-chave', () {
      expect(gm.reply('Crie um NPC'), contains('NPC gerado'));
      expect(gm.reply('Monte um encontro de combate'), contains('Encontro'));
      expect(gm.reply('Me dê uma ideia de missão'), contains('missão'));
      expect(gm.reply('Dicas para o mestre'), contains('para o Mestre'));
      expect(gm.reply('O que você pode fazer, IA?'), contains('O que eu posso fazer'));
    });

    test('modo mestre sempre oferece opções', () {
      expect(gm.reply('Começar aventura', system: 'Tormenta20'), contains('Tormenta20'));
      expect(gm.reply('Eu abro a porta'), contains('O que você faz?'));
    });
  });

  testWidgets('Assistente IA: sugestões, dados e modo dicas (offline)', (tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: AssistantView()));
    expect(find.text('Mestre IA'), findsWidgets);

    await tester.tap(find.text('Começar aventura'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Modo offline'), findsOneWidget);
    expect(find.textContaining('O que você faz?', findRichText: true), findsWidgets);

    await tester.ensureVisible(find.text('O que a IA faz?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('O que a IA faz?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('O que eu posso fazer', findRichText: true), findsOneWidget);
  });

  testWidgets('Marketplace de parceiros exibe produtos, comissões e portal de venda',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: MarketplaceView()));
    expect(find.text('Marketplace Oficial de Parceiros'), findsOneWidget);
    expect(find.textContaining('Comissão'), findsWidgets);

    // Abre o portal de parceiros / simulador de comissão
    await tester.tap(find.text('Vender'));
    await tester.pumpAndSettle();
    expect(find.text('Portal de Parceiros & Comissão'), findsOneWidget);
    expect(find.text('Simulador de Repasse e Comissão'), findsOneWidget);
  });

  testWidgets('Explorar exibe Mesas, Heróis e Locais para Jogar RPG', (tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: TableSearchView()));
    await tester.pumpAndSettle();

    // Alterna para a aba de Locais
    await tester.tap(find.text('Locais'));
    await tester.pumpAndSettle();
    expect(find.text('Locais para Jogar RPG'), findsOneWidget);
    expect(find.text('Taverna do Dado Dourado'), findsOneWidget);
  });

  test('ChatService gera ids de sala estáveis', () {
    expect(ChatService.roomIdFromTitle('Taverna do Dragão'), 'taverna-do-dragao');
    expect(ChatService.roomIdFromTitle('  Sombras sobre Arkham! '), 'sombras-sobre-arkham');
  });
}
