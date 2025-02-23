import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:chatbotapp/apis/api_service.dart';
import 'package:chatbotapp/constants/constants.dart';
import 'package:chatbotapp/hive/boxes.dart';
import 'package:chatbotapp/hive/chat_history.dart';
import 'package:chatbotapp/hive/settings.dart';
import 'package:chatbotapp/hive/user_model.dart';
import 'package:chatbotapp/models/message.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class ChatProvider extends ChangeNotifier {
  void init() {
    fetchNews();
  }

  // list of messages
  final List<Message> _inChatMessages = [];

  // page controller
  final PageController _pageController = PageController();

  // images file list
  List<XFile>? _imagesFileList = [];

  // index of the current screen
  int _currentIndex = 0;

  // cuttent chatId
  String _currentChatId = '';

  // loading bool
  bool _isLoading = false;

  List<Map<String, dynamic>> newsItems = [];

  // getters
  List<Message> get inChatMessages => _inChatMessages;

  PageController get pageController => _pageController;

  List<XFile>? get imagesFileList => _imagesFileList;

  int get currentIndex => _currentIndex;

  String get currentChatId => _currentChatId;

  bool get isLoading => _isLoading;

  // setters

  // set inChatMessages
  Future<void> setInChatMessages({required String chatId}) async {
    // get messages from hive database
    final messagesFromDB = await loadMessagesFromDB(chatId: chatId);

    for (var message in messagesFromDB) {
      if (_inChatMessages.contains(message)) {
        log('message already exists');
        continue;
      }

      _inChatMessages.add(message);
    }
    notifyListeners();
  }

  // load the messages from db
  Future<List<Message>> loadMessagesFromDB({required String chatId}) async {
    // open the box of this chatID
    await Hive.openBox('${Constants.chatMessagesBox}$chatId');

    final messageBox = Hive.box('${Constants.chatMessagesBox}$chatId');

    final newData = messageBox.keys.map((e) {
      final message = messageBox.get(e);
      final messageData = Message.fromMap(Map<String, dynamic>.from(message));

      return messageData;
    }).toList();
    notifyListeners();
    return newData;
  }

  // set file list
  void setImagesFileList({required List<XFile> listValue}) {
    _imagesFileList = listValue;
    notifyListeners();
  }

  // set current page index
  void setCurrentIndex({required int newIndex}) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  // set current chat id
  void setCurrentChatId({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  // set loading
  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

//?Yeha bata copy

  // delete caht
  Future<void> deleteChatMessages({required String chatId}) async {
    // 1. check if the box is open
    if (!Hive.isBoxOpen('${Constants.chatMessagesBox}$chatId')) {
      // open the box
      await Hive.openBox('${Constants.chatMessagesBox}$chatId');

      // delete all messages in the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();

      // close the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    } else {
      // delete all messages in the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();

      // close the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    }

    // get the current chatId, its its not empty
    // we check if its the same as the chatId
    // if its the same we set it to empty
    if (currentChatId.isNotEmpty) {
      if (currentChatId == chatId) {
        setCurrentChatId(newChatId: '');
        _inChatMessages.clear();
        notifyListeners();
      }
    }
  }

  // prepare chat room
  Future<void> prepareChatRoom({
    required bool isNewChat,
    required String chatID,
  }) async {
    if (!isNewChat) {
      // 1.  load the chat messages from the db
      final chatHistory = await loadMessagesFromDB(chatId: chatID);

      // 2. clear the inChatMessages
      _inChatMessages.clear();

      for (var message in chatHistory) {
        _inChatMessages.add(message);
      }

      // 3. set the current chat id
      setCurrentChatId(newChatId: chatID);
    } else {
      // 1. clear the inChatMessages
      _inChatMessages.clear();

      // 2. set the current chat id
      setCurrentChatId(newChatId: chatID);
    }
  }

//?yeha samma

  // send message to gemini and get the streamed reposnse
  Future<void> sentMessage({
    required String message,
    required bool isTextOnly,
  }) async {
    // set loading
    setLoading(value: true);

    // get the chatId
    String chatId = getChatId();

    // list of history messahes
    List<Content> history = [];

    // get the chat history
    history = await getHistory(chatId: chatId);

    // get the imagesUrls
    List<String> imagesUrls = getImagesUrls(isTextOnly: isTextOnly);

//??Copy
    // open the messages box
    final messagesBox =
        await Hive.openBox('${Constants.chatMessagesBox}$chatId');

    // get the last user message id
    final userMessageId = messagesBox.keys.length;

    // assistant messageId
    final assistantMessageId = messagesBox.keys.length + 1;

// ?yeha samma

    // user message
    final userMessage = Message(
      messageId: userMessageId.toString(),
      chatId: chatId,
      role: Role.user,
      message: StringBuffer(message),
      imagesUrls: imagesUrls,
      timeSent: DateTime.now(),
    );

    // add this message to the list on inChatMessages
    _inChatMessages.add(userMessage);
    notifyListeners();

    if (currentChatId.isEmpty) {
      setCurrentChatId(newChatId: chatId);
    }
    setLoading(value: true);
    notifyListeners();

    try {
      // Future<http.Response> response = http.post(
      //   Uri.parse('http://localhost/upload'),
      //   headers: <String, String>{
      //     'Content-Type': 'multipart/form-data; charset=UTF-8',
      //   },
      //   body: jsonEncode(<String, String>{'file': title}),
      // );
      final uri = Uri.parse('http://192.168.137.10:4000/upload');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', imagesUrls[0],
          contentType: MediaType('image', 'jpeg')));

      request
          .send()
          .then((result) async {
            http.Response.fromStream(result).then((response) {
              if (response.statusCode == 200) {
                print("Uploaded! ");
                print('response.body ' + response.body);
              } else {
                print('response.body ' + response.body);
              }

              final Message assistantMessage1 = Message(
                  messageId: (userMessage.messageId + '1'),
                  chatId: chatId,
                  message: StringBuffer(response.body),
                  imagesUrls: imagesUrls,
                  timeSent: DateTime.now(),
                  role: Role.assistant);
              saveMessagesToDB(
                chatID: chatId,
                userMessage: userMessage,
                assistantMessage: assistantMessage1,
                messagesBox: messagesBox,
              );
              setLoading(value: false);
              notifyListeners();
            });
          })
          .catchError((err) => print('error : ' + err.toString()))
          .whenComplete(() {
            setLoading(value: false);
            notifyListeners();
          });
    } catch (e) {
      log(e.toString());
    }
// // ? change is here
//     // send the message to the model and wait for the response
//     await sendMessageAndWaitForResponse(
//       message: message,
//       chatId: chatId,
//       isTextOnly: isTextOnly,
//       history: history,
//       userMessage: userMessage,
//       modelMessageId: assistantMessageId.toString(),
//       messagesBox: messagesBox,
//     );
  }

  // // send message to the model and wait for the response
  // Future<void> sendMessageAndWaitForResponse({
  //   required String message,
  //   required String chatId,
  //   required bool isTextOnly,
  //   required List<Content> history,
  //   required Message userMessage,
  //   required String modelMessageId, // ? Add this line
  //   required Box messagesBox,
  // }) async {
  //   // get content
  //   final content = await getContent(
  //     message: message,
  //     isTextOnly: isTextOnly,
  //   );

  //   // wait for stream response
  //   chatSession.sendMessageStream(content).asyncMap((event) {
  //     return event;
  //   }).listen((event) {
  //     _inChatMessages
  //         .firstWhere((element) =>
  //             element.messageId == assistantMessage.messageId &&
  //             element.role.name == Role.assistant.name)
  //         .message
  //         .write(event.text);
  //     log('event: ${event.text}');
  //     notifyListeners();
  //   }, onDone: () async {
  //     log('Message received');
  //     // save message to hive db
  //     await
  //     // set loading to false
  //     setLoading(value: false);
  //   }).onError((erro, stackTrace) {
  //     log('error: $erro');
  //     // set loading
  //     setLoading(value: false);
  //   }
  //   );
  // }

  // save messages to hive db
  Future<void> saveMessagesToDB({
    required String chatID,
    required Message userMessage,
    required Message assistantMessage,
    required Box messagesBox,
  }) async {
    // save the user messages
    await messagesBox.add(userMessage.toMap());

    // save the assistant messages
    await messagesBox.add(assistantMessage.toMap());

    // save chat history with thae same chatId
    // if its already there update it
    // if not create a new one
    final chatHistoryBox = Boxes.getChatHistory();

    final chatHistory = ChatHistory(
      chatId: chatID,
      prompt: userMessage.message.toString(),
      response: assistantMessage.message.toString(),
      imagesUrls: userMessage.imagesUrls,
      timestamp: DateTime.now(),
    );
    await chatHistoryBox.put(chatID, chatHistory);

    // close the box
    await messagesBox.close();
  }

  Future<Content> getContent({
    required String message,
    required bool isTextOnly,
  }) async {
    if (isTextOnly) {
      // generate text from text-only input
      return Content.text(message);
    } else {
      // generate image from text and image input
      final imageFutures = _imagesFileList
          ?.map((imageFile) => imageFile.readAsBytes())
          .toList(growable: false);

      final imageBytes = await Future.wait(imageFutures!);
      final prompt = TextPart(message);
      final imageParts = imageBytes
          .map((bytes) => DataPart('image/jpeg', Uint8List.fromList(bytes)))
          .toList();

      return Content.multi([prompt, ...imageParts]);
    }
  }

  // get y=the imagesUrls
  List<String> getImagesUrls({
    required bool isTextOnly,
  }) {
    List<String> imagesUrls = [];
    if (!isTextOnly && imagesFileList != null) {
      for (var image in imagesFileList!) {
        imagesUrls.add(image.path);
      }
    }
    return imagesUrls;
  }

  Future<List<Content>> getHistory({required String chatId}) async {
    List<Content> history = [];
    if (currentChatId.isNotEmpty) {
      await setInChatMessages(chatId: chatId);

      for (var message in inChatMessages) {
        if (message.role == Role.user) {
          history.add(Content.text(message.message.toString()));
        } else {
          history.add(Content.model([TextPart(message.message.toString())]));
        }
      }
    }

    return history;
  }

  String getChatId() {
    if (currentChatId.isEmpty) {
      return const Uuid().v4();
    } else {
      return currentChatId;
    }
  }

  // init Hive box
  static initHive() async {
    final dir = await path.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    await Hive.initFlutter(Constants.geminiDB);

    // register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());

      // open the chat history box
      await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
      await Hive.openBox<UserModel>(Constants.userBox);
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
      await Hive.openBox<Settings>(Constants.settingsBox);
    }
  }

  Future<void> fetchNews() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.137.10:4000/get-agriculture-news'));
      if (response.statusCode == 200) {
        newsItems = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        notifyListeners();
      }
    } catch (e) {
      log('Error fetching news: $e');
    }
  }
}
