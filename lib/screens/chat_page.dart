import 'package:flutter/material.dart';
import 'package:probahini/services/chat_service.dart';
import 'package:probahini/widgets/chat_input.dart';
import 'package:probahini/widgets/typing_indicator.dart';
import '../utils/app_localizations.dart';
import '../widgets/chat_message.dart';
import '../models/message.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isFirstBuild = true;
  bool _isBotTyping = false;
  late String _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstBuild) {
      _addInitialMessage();
      _isFirstBuild = false;
    }
    _userId = const Uuid().v4();
  }

  void _addInitialMessage() {
    final localizations = AppLocalizations.of(context);
    final message = Message(
      text: localizations.translate('hello'),
      isUser: false,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(message);
    });
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = Message(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isBotTyping = true;
    });

    _scrollToBottom();

    try {
      final chatService = ChatService();
      final response = await chatService.sendChatQuery(
        userId: _userId,
        query: text,
      );

      setState(() {
        _isBotTyping = false;
        final botResponse = Message(
          text:
              response['response'] ??
              'Sorry, I couldn\'t process your request.',
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(botResponse);
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isBotTyping = false;
        final errorMessage = Message(
          text: 'Error: $e',
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(errorMessage);
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('app_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isBotTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isBotTyping && index == _messages.length) {
                  return const TypingIndicator(); // Show typing indicator
                }
                return ChatMessage(message: _messages[index]);
              },
            ),
          ),
          ChatInput(onSendMessage: _sendMessage),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
