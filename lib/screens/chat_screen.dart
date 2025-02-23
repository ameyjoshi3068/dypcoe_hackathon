import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatbotapp/providers/chat_provider.dart';
import 'package:chatbotapp/utility/animated_dialog.dart';
import 'package:chatbotapp/widgets/bottom_chat_field.dart';
import 'package:chatbotapp/widgets/chat_messages.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: chatProvider.inChatMessages.isEmpty
                        // ? Container()
                        ? Column(
                            children: [
                              // News Section Header
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Latest Agricultural News',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // News Cards
                              Container(
                                height:
                                    300, // Increased height for better visibility
                                child: ListView.builder(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: chatProvider.newsItems.length,
                                  itemBuilder: (context, index) {
                                    try {
                                      final newsItem =
                                          chatProvider.newsItems[index];
                                      return Card(
                                        margin: EdgeInsets.only(bottom: 16),
                                        child: ListTile(
                                          title: Text(
                                            newsItem['title'] ?? 'No title',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          subtitle: Text(
                                            'Published: ${newsItem['published'] ?? 'No date'}',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          onTap: () async {
                                            final url = newsItem['link'];
                                            if (url != null) {
                                              try {
                                                Uri uri = Uri.parse(url);
                                                if (await canLaunchUrl(uri)) {
                                                  await launchUrl(uri);
                                                }
                                              } catch (e) {
                                                print(
                                                    'Error launching URL: $e');
                                              }
                                            }
                                          },
                                        ),
                                      );
                                    } catch (e) {
                                      print('Error building news item: $e');
                                      return Container();
                                    }
                                  },
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text('Start a conversation'),
                                ),
                              ),
                            ],
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
