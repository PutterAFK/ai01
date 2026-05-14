import 'package:flutter/material.dart';
import 'package:mindmate/core/constants/app_colors.dart';
import 'package:mindmate/core/widgets/network_status_banner.dart';
import 'package:mindmate/providers/chat_provider.dart';
import 'package:provider/provider.dart';

import 'widgets/message_bubble.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/typing_indicator.dart';
import 'chat_drawer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState
    extends State<ChatScreen> {

  final ScrollController
      _scrollController =
      ScrollController();

  final GlobalKey<
          ScaffoldState>
      _scaffoldKey =
      GlobalKey<
          ScaffoldState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding
        .instance
        .addPostFrameCallback(
      (_) {

        context
            .read<
                ChatProvider>()
            .loadConversations();

      },
    );
  }

  @override
  void dispose() {
    _scrollController
        .dispose();

    super.dispose();
  }

  void _scrollToBottom() {

    WidgetsBinding
        .instance
        .addPostFrameCallback(
      (_) {

        if (
            _scrollController
                .hasClients) {

          _scrollController
              .animateTo(
            _scrollController
                .position
                .maxScrollExtent,

            duration:
                const Duration(
              milliseconds:
                  300,
            ),

            curve:
                Curves
                    .easeOut,
          );

        }

      },
    );

  }

  @override
  Widget build(
      BuildContext
          context) {

    return Scaffold(

      key:
          _scaffoldKey,

      resizeToAvoidBottomInset:
          true,

      backgroundColor:
          Theme.of(
        context,
      ).scaffoldBackgroundColor,

      drawer:
          const ChatDrawer(),

      appBar:
          _buildAppBar(),

      body:
          NetworkStatusBanner(

        child:
            Column(

          children: [

            Expanded(
              child:
                  _buildMessageList(),
            ),

            ChatInputBar(

              onSend:
                  (
                message,
              ) async {

                await context
                    .read<
                        ChatProvider>()
                    .sendMessage(
                      message,
                    );

                _scrollToBottom();

              },

            ),

          ],

        ),

      ),

    );

  }

  PreferredSizeWidget
      _buildAppBar() {

    final isDark =
        Theme.of(
              context,
            )
                .brightness ==
            Brightness
                .dark;

    return AppBar(

      backgroundColor:
          Theme.of(
        context,
      ).cardColor,

      elevation:
          0,

      leading:
          IconButton(

        icon: Icon(

          Icons.menu,

          color:
              isDark
                  ? AppColors
                      .textPrimaryDark
                  : AppColors
                      .textPrimaryLight,

        ),

        onPressed:
            () {

          _scaffoldKey
              .currentState
              ?.openDrawer();

        },

      ),

      title:
          Column(

        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [

          Text(

            "MindMate",

            style:
                TextStyle(

              fontSize:
                  16,

              fontWeight:
                  FontWeight
                      .bold,

              color:
                  isDark
                      ? AppColors
                          .textPrimaryDark
                      : AppColors
                          .textPrimaryLight,

            ),

          ),

          Text(

            "พร้อมรับฟังคุณเสมอ 🧡",

            style:
                TextStyle(

              fontSize:
                  12,

              color:
                  isDark
                      ? AppColors
                          .textSecondaryDark
                      : AppColors
                          .textSecondaryLight,

            ),

          ),

        ],

      ),

      actions: [

        IconButton(

          icon:
              Icon(

            Icons
                .add_comment_outlined,

            color:
                isDark
                    ? AppColors
                        .textPrimaryDark
                    : AppColors
                        .textPrimaryLight,

          ),

          onPressed:
              () {

            context
                .read<
                    ChatProvider>()
                .startNewChat();

          },

        ),

      ],

    );

  }

  Widget
      _buildMessageList() {

    return Consumer<
        ChatProvider>(

      builder:
          (
        context,
        chatProvider,
        _,
      ) {

        if (
            chatProvider
                .isLoading) {

          return const Center(

            child:
                CircularProgressIndicator(
              color:
                  AppColors
                      .primary,
            ),

          );

        }

        if (
            chatProvider
                        .currentConversationId ==
                    null ||
                chatProvider
                    .messages
                    .isEmpty) {

          return _buildWelcomeMessage();

        }

        return ListView.builder(

          controller:
              _scrollController,

          padding:
              const EdgeInsets.symmetric(
            horizontal:
                16,
            vertical:
                16,
          ),

          itemCount:

              chatProvider
                      .messages
                      .length +

                  (
                    chatProvider
                            .isTyping
                        ? 1
                        : 0
                  ),

          itemBuilder:
              (
            context,
            index,
          ) {

            if (
                index ==
                    chatProvider
                        .messages
                        .length) {

              return const TypingIndicator();

            }

            return MessageBubble(

              message:
                  chatProvider
                      .messages[index],

            );

          },

        );

      },

    );

  }

  Widget
      _buildWelcomeMessage() {

    final isDark =
        Theme.of(
              context,
            )
                .brightness ==
            Brightness
                .dark;

    return Center(

      child:
          Column(

        mainAxisAlignment:
            MainAxisAlignment
                .center,

        children: [

          Container(

            width:
                80,

            height:
                80,

            decoration:
                BoxDecoration(

              color:
                  AppColors
                      .primaryLight,

              borderRadius:
                  BorderRadius.circular(
                24,
              ),

            ),

            child:
                const Icon(

              Icons.favorite,

              color:
                  Colors
                      .white,

              size:
                  40,

            ),

          ),

          const SizedBox(
            height:
                24,
          ),

          Text(

            "วันนี้เป็นยังไงบ้าง",

            style:
                TextStyle(

              fontSize:
                  24,

              fontWeight:
                  FontWeight
                      .bold,

              color:
                  isDark
                      ? AppColors
                          .textPrimaryDark
                      : AppColors
                          .textPrimaryLight,

            ),

          ),

          const SizedBox(
            height:
                8,
          ),

          Text(

            "พื้นที่นี้เป็นของคุณเสมอ\nวันนี้มีเรื่องอะไรอยากให้เราช่วยฟังไหม",

            textAlign:
                TextAlign
                    .center,

            style:
                TextStyle(

              fontSize:
                  16,

              height:
                  1.5,

              color:
                  isDark
                      ? AppColors
                          .textSecondaryDark
                      : AppColors
                          .textSecondaryLight,

            ),

          ),

          const SizedBox(
            height:
                32,
          ),

          ElevatedButton.icon(

            onPressed:
                () {

              context
                  .read<
                      ChatProvider>()
                  .startNewChat();

            },

            icon:
                const Icon(
              Icons
                  .add,
            ),

            label:
                const Text(
              "เริ่มต้นพูดคุย",
            ),

            style:
                ElevatedButton.styleFrom(

              backgroundColor:
                  AppColors
                      .primary,

              foregroundColor:
                  Colors
                      .white,

              padding:
                  const EdgeInsets.symmetric(
                horizontal:
                    24,
                vertical:
                    12,
              ),

              shape:
                  RoundedRectangleBorder(

                borderRadius:
                    BorderRadius.circular(
                  12,
                ),

              ),

            ),

          ),

        ],

      ),

    );

  }

}
