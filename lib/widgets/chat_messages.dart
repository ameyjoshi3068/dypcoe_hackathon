import 'dart:convert';

import 'package:chatbotapp/models/disease.dart';
import 'package:chatbotapp/widgets/disease_details_widget.dart';
import 'package:flutter/material.dart';
import 'package:chatbotapp/models/message.dart';
import 'package:chatbotapp/providers/chat_provider.dart';
import 'package:chatbotapp/widgets/assistant_message_widget.dart';
import 'package:chatbotapp/widgets/my_message_widget.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({
    super.key,
    required this.scrollController,
    required this.chatProvider,
  });

  final ScrollController scrollController;
  final ChatProvider chatProvider;

  Disease getDisease() {
    try {
      final diseaseJson = chatProvider.inChatMessages.last.message.toString();
      final disease = Disease.fromJson(jsonDecode(diseaseJson));
      return disease;
    } catch (e) {
      print('Image Produced Invalid Results: $e   ');
      return Disease(
        url: '',
        identification: Identification(
          name: 'Invalid Image',
          description: 'Invalid Image',
          symptoms: [],
          severity: '',
          treatment: Treatment(
            prevention: [],
            chemical: [],
            biological: [],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: chatProvider.inChatMessages.length,
      itemBuilder: (context, index) {
        // compare with timeSent before showing the list
        final message = chatProvider.inChatMessages[index];
        return message.role.name == Role.user.name
            ? MyMessageWidget(message: message)
            : DiseaseDetailsWidget(disease: getDisease());
      },
    );
  }
}
