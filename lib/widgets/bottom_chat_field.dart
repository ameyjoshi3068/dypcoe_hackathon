import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatbotapp/providers/chat_provider.dart';
import 'package:chatbotapp/utility/animated_dialog.dart';
import 'package:chatbotapp/widgets/preview_images_widget.dart';
import 'package:image_picker/image_picker.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
    required this.chatProvider,
  });

  final ChatProvider chatProvider;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  // focus node for the input field
  final FocusNode textFieldFocus = FocusNode();

  // initialize image picker
  final ImagePicker _picker = ImagePicker();

  final List<String> cropItems = [
    "Rice",
    "Wheat",
    "Maize",
    "Barley",
    "Lentils",
    "Beans",
    "Soybean",
    "Groundnut",
    "Sunflower",
    "Tomato",
    "Potato",
    "Onion",
    "Brinjal (Eggplant)",
    "Mango",
    "Banana",
    "Apple",
    "Grapes",
    "Cotton",
    "Sugarcane",
    "Coffee",
  ];

  String? selectedCrop;

  @override
  void dispose() {
    textFieldFocus.dispose();
    super.dispose();
  }

  Future<void> sendChatMessage({
    required String message,
    required ChatProvider chatProvider,
    required bool isTextOnly,
  }) async {
    try {
      await chatProvider.sentMessage(
        message: message,
        isTextOnly: isTextOnly,
      );
    } catch (e) {
      log('error : $e');
    } finally {
      widget.chatProvider.setImagesFileList(listValue: []);
      textFieldFocus.unfocus();
    }
  }

  // pick an image
  void pickImage() async {
    try {
      final pickedImages = await _picker.pickMultiImage(
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 95,
      );
      widget.chatProvider.setImagesFileList(listValue: pickedImages);
    } catch (e) {
      log('error : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasImages = widget.chatProvider.imagesFileList != null &&
        widget.chatProvider.imagesFileList!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).textTheme.titleLarge!.color!,
        ),
      ),
      child: Column(
        children: [
          IconButton(
            onPressed: () {
              if (hasImages) {
                // show the delete dialog
                showMyAnimatedDialog(
                    context: context,
                    title: 'Delete Images',
                    content: 'Are you sure you want to delete the images?',
                    actionText: 'Delete',
                    onActionPressed: (value) {
                      if (value) {
                        widget.chatProvider.setImagesFileList(
                          listValue: [],
                        );
                      }
                    });
              } else {
                pickImage();
              }
            },
            icon: Icon(
              hasImages ? CupertinoIcons.delete : CupertinoIcons.photo,
            ),
          ),
          if (hasImages) const PreviewImagesWidget(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCrop,
                      hint: const Text('Select Crop'),
                      items: cropItems.map((String crop) {
                        return DropdownMenuItem<String>(
                          value: crop,
                          child: Text(crop),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCrop = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.chatProvider.isLoading
                    ? null
                    : () {
                        if (selectedCrop != null && hasImages) {
                          log("Request sent");
                          // send the message
                          sendChatMessage(
                            message: selectedCrop!,
                            chatProvider: widget.chatProvider,
                            isTextOnly: false,
                          );
                        }
                      },
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.all(5.0),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        // Icons.arrow_upward,
                        CupertinoIcons.arrow_up,
                        color: Colors.white,
                      ),
                    )),
              )
            ],
          ),
        ],
      ),
    );
  }
}
