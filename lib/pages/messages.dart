import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/chat_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/models/aux_models.dart';
import 'package:hair_main_street/models/message_model.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:hair_main_street/widgets/text_input.dart';

class MessagesPage extends StatefulWidget {
  final String? participant1;
  final String? participant2;
  const MessagesPage({this.participant1, this.participant2, super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final ScrollController scrollController = ScrollController();
  ChatController chatController = Get.find<ChatController>();

  UserController userController = Get.find<UserController>();
  MessagePageData? data;

  @override
  void initState() {
    super.initState();
    resolveMessageData([widget.participant1!, widget.participant2!]);
    chatController.getMessages(widget.participant1!, widget.participant2!);
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   if (scrollController.hasClients) {
    //     scrollController.jumpTo(scrollController.position.maxScrollExtent);
    //   }
    // });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<MessagePageData?> resolveMessageData(List<String> participants) async {
    String currentUserId = userController.userState.value!.uid!;
    for (var participant in participants) {
      if (participant != currentUserId) {
        return await chatController.resolveNameToDisplay(participant);
      } else {}
    }
    return null;
  }

  void scrollToEnd() {
    scrollController.animateTo(scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey();
    Chat chat = Chat(participants: []);
    ChatMessages chatMessages = ChatMessages(content: "");

    return FutureBuilder(
        future:
            resolveMessageData([widget.participant1!, widget.participant2!]),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: LoadingWidget(),
            );
          }
          return Scaffold(
            appBar: AppBar(
              leadingWidth: 40,
              centerTitle: true,
              scrolledUnderElevation: 0,
              elevation: 0,
              title: Text(
                snapshot.data!.name ?? "Message",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Lato",
                ),
              ),
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
            backgroundColor: Colors.white,
            body: Container(
              color: const Color(0xFF673AB7).withValues(alpha: 0.05),
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                        stream: DataBaseService().getChatsBetween2Users(
                          currentUserId: widget.participant1!,
                          otherUserId: widget.participant2!,
                        ),
                        builder: (context, snapshot) {
                          //print(snapshot.data);
                          if (snapshot.hasData) {
                            return GetX<ChatController>(
                              builder: (controller) {
                                return controller.messagesList.value!.isEmpty
                                    ? Center(
                                        child: const Text(
                                          "No Messages Yet",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontFamily: "Raleway",
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        reverse: false,
                                        controller: scrollController,
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 12, 12, 8),
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: controller
                                            .messagesList.value!.length,
                                        itemBuilder: (context, index) {
                                          //scrollToEnd();
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 4),
                                            child: ChatMessage(
                                                message: controller.messagesList
                                                    .value![index]!),
                                          );
                                        },
                                      );
                              },
                            );
                          } else {
                            return const Center(
                              heightFactor: 2,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            );
                          }
                        }),
                  ),
                  SafeArea(
                    child: Container(
                      color: AppColors.shade1,
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: Form(
                        key: formKey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 6,
                              child: TextInputWidgetWithoutLabel(
                                controller: messageController,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 0.5,
                                  ),
                                ),
                                hintText: "Message",
                                onChanged: (val) {
                                  chatController.isButtonEnabled.value =
                                      val!.trim().isNotEmpty;
                                  messageController.text = val;
                                  return null;
                                },
                                textInputType: TextInputType.multiline,
                                maxLines: 10,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              flex: 1,
                              child: Obx(
                                () => IconButton(
                                  style: IconButton.styleFrom(
                                    disabledBackgroundColor:
                                        const Color(0xFF673AB7),
                                    backgroundColor: const Color(0xFF673AB7),
                                    shape: const CircleBorder(),
                                  ),
                                  onPressed: chatController
                                          .isButtonEnabled.value
                                      ? () {
                                          String currentUserId = userController
                                              .userState.value!.uid!;
                                          chatMessages.senderID = currentUserId;
                                          chat.participants = [
                                            widget.participant1!,
                                            widget.participant2!
                                          ];
                                          chat.recentMessageSentBy =
                                              currentUserId;
                                          chatMessages.content =
                                              messageController.text;
                                          chat.recentMessageText =
                                              messageController.text;
                                          chatController.sendMessage(
                                            chatMessages,
                                            widget.participant1!,
                                            widget.participant2!,
                                          );
                                          messageController.clear();
                                          formKey.currentState!.reset();
                                          if (chatController
                                              .messagesList.value!.isNotEmpty) {
                                            scrollToEnd();
                                          }
                                        }
                                      : null,
                                  icon: const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class ChatMessage extends StatefulWidget {
  final ChatMessages message;

  const ChatMessage({
    super.key,
    required this.message,
  });

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  UserController userController = Get.find<UserController>();
  ChatController chatController = Get.find<ChatController>();
  Future? myFuture;

  @override
  void initState() {
    super.initState();
    //myFuture = chatController.resolveTheNames(widget.message);
  }

  @override
  Widget build(BuildContext context) {
    num screenWidth = Get.width;
    // DateTime resolveTimestampWithoutAdding(Timestamp timestamp) {
    //   final timestampDateTime = timestamp.toDate();

    //   return DateTime(
    //     0,
    //     0,
    //     0,
    //     timestampDateTime.hour,
    //     timestampDateTime.minute,
    //     timestampDateTime.second,
    //   );
    // }

    return GetX<ChatController>(builder: (controller) {
      bool isUsertheSender =
          widget.message.senderID == userController.userState.value!.uid;
      return Align(
        alignment:
            isUsertheSender ? Alignment.centerRight : Alignment.centerLeft,
        child: isUsertheSender
            ? Row(
                mainAxisAlignment: isUsertheSender
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  Container(
                    //width: screenWidth * 0.50,
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.80),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: const Color(0xFF673AB7),
                    ),
                    child: SelectableText(
                      widget.message.content!,
                      maxLines: 15,
                      minLines: 1,
                      // overflow: TextOverflow.ellipsis,
                      // softWrap: true,
                      style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  FutureBuilder(
                      future: chatController
                          .resolveNameToDisplay(widget.message.senderID!),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.connectionState ==
                                ConnectionState.waiting) {
                          return const CircleAvatar(
                            radius: 18,
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return snapshot.data!.imageUrl == null ||
                                  snapshot.data!.imageUrl!.isEmpty
                              ? CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: SvgPicture.asset(
                                    "assets/Icons/user.svg",
                                    colorFilter: ColorFilter.mode(
                                      Colors.black,
                                      BlendMode.srcIn,
                                    ),
                                    height: 24,
                                    width: 24,
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(
                                    snapshot.data!.imageUrl!,
                                  ),
                                );
                        }
                      }),
                ],
              )
            : Row(
                mainAxisAlignment: isUsertheSender
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  FutureBuilder(
                      future: chatController
                          .resolveNameToDisplay(widget.message.senderID!),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.connectionState ==
                                ConnectionState.waiting) {
                          return const CircleAvatar(
                            radius: 18,
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return snapshot.data!.imageUrl == null ||
                                  snapshot.data!.imageUrl!.isEmpty
                              ? CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: SvgPicture.asset(
                                    "assets/Icons/user.svg",
                                    colorFilter: ColorFilter.mode(
                                      Colors.black,
                                      BlendMode.srcIn,
                                    ),
                                    height: 24,
                                    width: 24,
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(
                                    snapshot.data!.imageUrl!,
                                  ),
                                );
                        }
                      }),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.80),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                      border: Border.all(
                        width: 0.5,
                        color: Colors.black38,
                      ),
                    ),
                    child: SelectableText(
                      widget.message.content!,
                      style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
      );
    });
  }
}
