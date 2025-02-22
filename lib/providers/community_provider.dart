import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class CommunityMessage {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String cropImage;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String senderName;

  @HiveField(4)
  final String senderPlace;

  @HiveField(5)
  final String profileImage;

  @HiveField(6)
  int likes;

  @HiveField(7)
  int dislikes;

  CommunityMessage({
    required this.title,
    required this.cropImage,
    required this.description,
    required this.senderName,
    required this.senderPlace,
    required this.profileImage,
    this.likes = 0,
    this.dislikes = 0,
  });
}

class CommunityProvider with ChangeNotifier {
  final List<CommunityMessage> _messages = [
    CommunityMessage(
      title: "Wheat Leaves Turning Yellow",
      cropImage: "assets/wheat_disease.png",
      description:
          "My wheat crop is showing yellow patches on the leaves. Could this be rust disease? Need urgent advice!",
      senderName: "Rajesh Kumar",
      senderPlace: "Punjab, India",
      profileImage: "assets/profiles/rajesh.jpg",
      likes: 5,
      dislikes: 0,
    ),
    CommunityMessage(
      title: "Tomato Plants Wilting Rapidly",
      cropImage: "assets/tomato_disease.jpg",
      description:
          "The leaves of my tomato plants are drooping and turning brown. Is this late blight? What should I do?",
      senderName: "Anita Sharma",
      senderPlace: "Maharashtra, India",
      profileImage: "assets/profiles/anita.jpg",
      likes: 8,
      dislikes: 1,
    ),
    CommunityMessage(
      title: "Sunflower Leaves Developing White Spots",
      cropImage: "assets/sunflower_disease.jpg",
      description:
          "Noticed small white spots on my sunflower leaves. Could this be a fungal infection? Any organic solutions?",
      senderName: "John Doe",
      senderPlace: "Texas, USA",
      profileImage: "assets/profiles/john.jpg",
      likes: 10,
      dislikes: 2,
    ),
    CommunityMessage(
      title: "Apple Trees Affected by Scab",
      cropImage: "assets/apple_disease.jpg",
      description:
          "Fruits have dark scabby spots and leaves look unhealthy. How can I prevent apple scab from spreading?",
      senderName: "Emily Watson",
      senderPlace: "Washington, USA",
      profileImage: "assets/profiles/emily.jpg",
      likes: 12,
      dislikes: 0,
    ),
    CommunityMessage(
      title: "Mango Leaves Curling and Drying",
      cropImage: "assets/mango_disease.jpg",
      description:
          "My mango tree leaves are curling and turning brown. Is this due to pests or a fungal issue?",
      senderName: "Deepak Verma",
      senderPlace: "Uttar Pradesh, India",
      profileImage: "assets/profiles/deepak.jpg",
      likes: 7,
      dislikes: 1,
    ),
  ];

  List<CommunityMessage> get messages => _messages;

  void addMessage(CommunityMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  final Set<int> _likedMessages = {};
  final Set<int> _dislikedMessages = {};

  void likeMessage(int index) {
    if (_likedMessages.contains(index)) return; // Prevent multiple likes
    if (_dislikedMessages.contains(index)) {
      _dislikedMessages.remove(index);
      _messages[index].dislikes--; // Remove previous dislike
    }
    _messages[index].likes++;
    _likedMessages.add(index);
    notifyListeners();
  }

  void dislikeMessage(int index) {
    if (_dislikedMessages.contains(index)) return; // Prevent multiple dislikes
    if (_likedMessages.contains(index)) {
      _likedMessages.remove(index);
      _messages[index].likes--; // Remove previous like
    }
    _messages[index].dislikes++;
    _dislikedMessages.add(index);
    notifyListeners();
  }
}
