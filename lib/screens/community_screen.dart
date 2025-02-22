import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_provider.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final communityProvider = Provider.of<CommunityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Community"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: communityProvider.messages.length,
        itemBuilder: (context, index) {
          final message = communityProvider.messages[index];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sender info
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(message.profileImage),
                        radius: 20,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.senderName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(message.senderPlace,
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Crop Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      message.cropImage,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Title & Description
                  Text(
                    message.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(message.description),

                  // Like, Dislike, Share buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.thumb_up),
                            onPressed: () =>
                                communityProvider.likeMessage(index),
                          ),
                          Text("${message.likes}"),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.thumb_down),
                            onPressed: () =>
                                communityProvider.dislikeMessage(index),
                          ),
                          Text("${message.dislikes}"),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          // Implement sharing logic here
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
