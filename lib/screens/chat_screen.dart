import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatbotapp/providers/chat_provider.dart';
import 'package:chatbotapp/utility/animated_dialog.dart';
import 'package:chatbotapp/widgets/bottom_chat_field.dart';
import 'package:chatbotapp/widgets/chat_messages.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0.0) {
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
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.inChatMessages.isNotEmpty) {
          _scrollToBottom();
        }

        // auto scroll to bottom on new message
        chatProvider.addListener(() {
          if (chatProvider.inChatMessages.isNotEmpty) {
            _scrollToBottom();
          }
        });

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            centerTitle: true,
            title: const Text('Upload Plant Image'),
            actions: [
              if (chatProvider.inChatMessages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    child: IconButton(
                      icon: const Icon(CupertinoIcons.add),
                      onPressed: () async {
                        // show my animated dialog to start new chat
                        showMyAnimatedDialog(
                          context: context,
                          title: 'Upload New Image',
                          content: 'Are you sure?',
                          actionText: 'Yes',
                          onActionPressed: (value) async {
                            if (value) {
                              // prepare chat room
                              await chatProvider.prepareChatRoom(
                                  isNewChat: true, chatID: '');
                            }
                          },
                        );
                      },
                    ),
                  ),
                )
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: chatProvider.inChatMessages.isEmpty
                        ? const Center(
                            child: Text('No messages yet'),
                          )
                        : ChatMessages(
                            scrollController: _scrollController,
                            chatProvider: chatProvider,
                          ),
                  ),

                  // input field
                  chatProvider.inChatMessages.isEmpty
                      ? BottomChatField(
                          chatProvider: chatProvider,
                        )
                      : SizedBox()
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
