import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String sender;
  final String text;

  Message({required this.sender, required this.text});
}

ChatMessages chatMessageFromJson(String str) =>
    ChatMessages.fromJson(json.decode(str));

String chatMessagesToJson(ChatMessages data) => json.encode(data.toJson());

class ChatMessages {
  String? senderID;
  String? content;
  bool? isRead = false;
  Timestamp? timestamp;

  ChatMessages({
    this.senderID,
    this.isRead,
    this.content,
    this.timestamp,
  });

  factory ChatMessages.fromJson(Map<String, dynamic> json) => ChatMessages(
        senderID: json["senderID"],
        isRead: json["is read"],
        content: json["content"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "senderID": senderID,
        "is read": isRead,
        "content": content,
        "timestamp": FieldValue.serverTimestamp(),
      };
}

class Chat {
  String? chatID;
  List<String>? participants;
  String? recentMessageText;
  String? recentMessageSentBy;
  Timestamp? recentMessageSentAt;
  bool? readBy;

  Chat(
      {this.chatID,
      this.participants,
      this.readBy,
      this.recentMessageSentAt,
      this.recentMessageSentBy,
      this.recentMessageText});

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        chatID: json["chatID"],
        participants: List<String>.from(json["participants"]),
        readBy: json["read by"],
        recentMessageSentAt: json["recent message sent at"],
        recentMessageSentBy: json['recent message sent by'],
        recentMessageText: json['recent message text'],
      );

  Map<String, dynamic> toJson() => {
        "chatID": chatID,
        "participants": participants,
        "recent message sent at": FieldValue.serverTimestamp(),
        "recent message sent by": recentMessageSentBy,
        "recent message text": recentMessageText,
        "read by": readBy,
      };
}

class DatabaseChatResponse {
  String? chatID;
  String? member1;
  String? member2;
  String? recentMessageText;
  String? recentMessageSentBy;
  Timestamp? recentMessageSentAt;
  bool? readBy;
  List<ChatMessages>? messages; // Added the messages variable

  DatabaseChatResponse({
    this.chatID,
    this.member1,
    this.member2,
    this.readBy,
    this.recentMessageSentAt,
    this.recentMessageSentBy,
    this.recentMessageText,
    this.messages, // Added messages to the constructor
  });

  factory DatabaseChatResponse.fromJson(Map<String, dynamic> json) =>
      DatabaseChatResponse(
        chatID: json["chatID"],
        member1: json["member1"],
        readBy: json["read by"],
        recentMessageSentAt: json["recent message sent at"],
        recentMessageSentBy: json['recent message sent by'],
        recentMessageText: json['recent message text'],
        member2: json["member2"],
        messages: json["messages"] != null
            ? List<ChatMessages>.from(
                json["messages"]
                    .map((message) => ChatMessages.fromJson(message)),
              )
            : null, // Added message parsing
      );

  Map<String, dynamic> toJson() => {
        "chatID": chatID,
        "member1": member1,
        "member2": member2,
        "recent message sent at": recentMessageSentAt,
        "recent message sent by": recentMessageSentBy,
        "recent message text": recentMessageText,
        "read by": readBy,
        "messages": messages
            ?.map((message) => message.toJson())
            .toList(), // Added message serialization
      };
}
