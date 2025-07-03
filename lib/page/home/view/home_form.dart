import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:common_utils_services/models/message.dart';
import '../../../models/character.dart';
import '../../../models/frequent_question.dart';
import '../../../models/user_profile.dart';
import '../../common/common_loading.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../../services/settings_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plengi AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => HomeBloc(),
        child: const HomeForm(),
      ),
    );
  }
}

class HomeForm extends StatefulWidget {
  const HomeForm({super.key});

  @override
  State<HomeForm> createState() => _HomeFormState();
}

class _HomeFormState extends State<HomeForm> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(Init(context));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      context.read<HomeBloc>().add(SendMessage(_messageController.text));
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _scrollToBottomWithDelay() {
    Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
        _scrollToBottom();
      },
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8.0),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          final isUser = message.role == 'user';
                          return _buildMessageBubble(message, isUser);
                        },
                      ),
                    ),
                    if (state.messages.isEmpty) _buildFrequentQuestionsGrid(),
                    _buildMessageInput(state),
                  ],
                ),
                if (state.isLoading) const CommonLoading(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(Message message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(20.0),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: GestureDetector(
          onLongPress: () => _showMessageOptions(context, message.content),
          child: Text(
            message.content,
            style: TextStyle(
              color: isUser
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(HomeState state) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(25.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
              ),
              child: TextField(
                onTap: _scrollToBottomWithDelay,
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: '메시지를 입력하세요...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          IconButton(
            icon: Icon(state.isAiResponding ? Icons.close : Icons.send),
            onPressed: state.isAiResponding
                ? () => context.read<HomeBloc>().add(const CancelAiResponse())
                : _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildFrequentQuestionsGrid() {
    final _frequentQuestions = context.read<HomeBloc>().state.frequentQuestions;
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 2.5,
        ),
        itemCount: _frequentQuestions.length,
        itemBuilder: (context, index) {
          final question = _frequentQuestions[index];
          return GestureDetector(
            onTap: () {
              _messageController.text = question.question;
              _sendMessage();
            },
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    question.question,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMessageOptions(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('복사'),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: message));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('메시지가 복사되었습니다')));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettings(BuildContext parentContext) {
    final homeBloc = parentContext.read<HomeBloc>();

    final settingsService = SettingsService();
    final character = settingsService.getCharacter();
    final userProfile = settingsService.getUserProfile();

    final nameController = TextEditingController(text: character?.name ?? '');
    final ageController = TextEditingController(
      text: userProfile?.age.toString() ?? '',
    );
    String selectedGender = character?.gender ?? '여성';
    String selectedUserGender = userProfile?.gender ?? '여성';
    double kindnessLevel = character?.kindnessLevel.toDouble() ?? 3.0;
    String selectedPreset = character?.presetId ?? '';
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return BlocProvider.value(
          value: homeBloc,
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              // 저장된 프리셋 확인
              if (character != null) {
                // 프리셋 ID로 매칭 확인
                if (character.presetId != null &&
                    character.presetId!.isNotEmpty) {
                  selectedPreset = character.presetId!;
                } else {
                  nameController.text = character.name;
                  selectedGender = character.gender;
                  kindnessLevel = character.kindnessLevel.toDouble();
                }
              }
              if (userProfile != null) {
                ageController.text = userProfile.age.toString();
                selectedUserGender = userProfile.gender;
              }
              return Container(
                padding: const EdgeInsets.only(top: 20),
                height: MediaQuery.of(context).size.height * 0.9,
                child: Scaffold(
                  backgroundColor: Colors.white10,
                  body: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '설정',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const Divider(),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'AI 캐릭터 설정',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // 프리셋 선택
                                  DropdownButtonFormField<String>(
                                    value: selectedPreset.isEmpty
                                        ? null
                                        : selectedPreset,
                                    decoration: const InputDecoration(
                                      labelText: '캐릭터 프리셋',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: '',
                                        child: Text('직접 설정'),
                                      ),
                                      ...SettingsService
                                          .characterPresets
                                          .entries
                                          .map((preset) {
                                            return DropdownMenuItem<String>(
                                              value: preset.key,
                                              child: Text(
                                                '${preset.value['name']} (${preset.value['age']}세, ${preset.value['gender']}, 친절도 ${preset.value['kindnessLevel']})',
                                              ),
                                            );
                                          })
                                          .toList(),
                                    ],
                                    onChanged: (value) {
                                      selectedPreset = value ?? '';
                                      if (value != null && value.isNotEmpty) {
                                        final preset = SettingsService
                                            .characterPresets[value]!;
                                        nameController.text =
                                            preset['name'] as String;
                                        selectedGender =
                                            preset['gender'] as String;
                                        kindnessLevel =
                                            (preset['kindnessLevel'] as int)
                                                .toDouble();
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // 상세 설정
                                  if (selectedPreset.isEmpty) ...[
                                    TextField(
                                      controller: nameController,
                                      decoration: const InputDecoration(
                                        labelText: '캐릭터 이름',
                                        border: OutlineInputBorder(),
                                      ),
                                      onSubmitted: (value) {},
                                    ),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      value: selectedGender,
                                      decoration: const InputDecoration(
                                        labelText: '성별',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: '여성',
                                          child: Text('여성'),
                                        ),
                                        DropdownMenuItem(
                                          value: '남성',
                                          child: Text('남성'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        selectedGender = value!;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('친절도: ${kindnessLevel.round()}'),
                                        Slider(
                                          value: kindnessLevel,
                                          min: 1,
                                          max: 5,
                                          divisions: 4,
                                          label: kindnessLevel
                                              .round()
                                              .toString(),
                                          onChanged: (value) {
                                            kindnessLevel = value;
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 32),
                                  const Text(
                                    '사용자 정보',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: ageController,
                                    decoration: const InputDecoration(
                                      labelText: '나이',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onSubmitted: (value) {},
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    value: selectedUserGender,
                                    decoration: const InputDecoration(
                                      labelText: '성별',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: '여성',
                                        child: Text('여성'),
                                      ),
                                      DropdownMenuItem(
                                        value: '남성',
                                        child: Text('남성'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      selectedUserGender = value!;
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (nameController.text.isNotEmpty &&
                                          ageController.text.isNotEmpty) {
                                        final character = Character(
                                          name: nameController.text,
                                          gender: selectedGender,
                                          kindnessLevel: kindnessLevel.round(),
                                          presetId: selectedPreset.isEmpty
                                              ? null
                                              : selectedPreset,
                                        );

                                        final userProfile = UserProfile(
                                          age: int.parse(ageController.text),
                                          gender: selectedUserGender,
                                        );

                                        await settingsService.saveCharacter(
                                          character,
                                        );
                                        await settingsService.saveUserProfile(
                                          userProfile,
                                        );
                                        if (!context.mounted) return;
                                        // 채팅 히스토리 삭제 전 확인 팝업
                                        final bool?
                                        shouldReset = await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('채팅 히스토리 초기화'),
                                              content: const Text(
                                                '설정이 변경되어 채팅 히스토리가 초기화됩니다. 계속하시겠습니까?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text('취소'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text('초기화'),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (shouldReset == true) {
                                          if (!context.mounted) return;
                                          context.read<HomeBloc>().add(
                                            ResetConversation(),
                                          );
                                          Navigator.pop(modalContext);
                                          ScaffoldMessenger.of(
                                            parentContext,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                '설정이 저장되었습니다. 채팅 히스토리가 초기화되었습니다.',
                                              ),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            parentContext,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('설정이 저장되었습니다'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                          Navigator.pop(modalContext);
                                        }
                                      } else {
                                        debugPrint("rymins showing");
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('모든 필드를 입력해주세요'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text('설정 저장'),
                                  ),
                                  const SizedBox(height: 32),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(Icons.delete_outline),
                                    title: const Text('대화 내용 초기화'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      context.read<HomeBloc>().add(
                                        ResetConversation(),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.my_location),
                                    title: const Text('현재 위치 확인'),
                                    onTap: () async {
                                      context.read<HomeBloc>().add(
                                        CheckCurrentLocation(),
                                      );

                                      // todo rymins
                                      // if (!hasPermission) {
                                      //   ScaffoldMessenger.of(modalContext).showSnackBar(
                                      //     const SnackBar(
                                      //       content: Text(
                                      //         '위치 권한이 허용되지 않아 위치 정보를 가져올 수 없습니다.',
                                      //       ),
                                      //       duration: Duration(seconds: 2),
                                      //     ),
                                      //   );
                                      //   return;
                                      // }
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.history),
                                    title: const Text('위치 히스토리 확인'),
                                    onTap: () {
                                      context.read<HomeBloc>().add(
                                        ShowLocationHistory(),
                                      );
                                      // final history =
                                      //     _locationHistoryManager.locationHistory;
                                      // if (history.isEmpty) {
                                      //     ScaffoldMessenger.of(modalContext).showSnackBar(
                                      //       const SnackBar(
                                      //         content: Text('저장된 위치 히스토리가 없습니다.'),
                                      //         duration: Duration(seconds: 2),
                                      //       ),
                                      //     );
                                      //   return;
                                      // }

                                      // if (mounted) {
                                      //   showDialog(
                                      //     context: context,
                                      //     builder: (BuildContext dialogContext) {
                                      //       return AlertDialog(
                                      //         title: const Text('위치 히스토리'),
                                      //         content: SizedBox(
                                      //           width: double.maxFinite,
                                      //           height: 300,
                                      //           child: ListView.builder(
                                      //             itemCount: history.length,
                                      //             itemBuilder: (context, index) {
                                      //               final location = history[index];
                                      //               return ListTile(
                                      //                 leading: CircleAvatar(
                                      //                   backgroundColor: Theme.of(
                                      //                     context,
                                      //                   ).colorScheme.primary,
                                      //                   child: Text(
                                      //                     '${index + 1}',
                                      //                     style: TextStyle(
                                      //                       color: Theme.of(
                                      //                         context,
                                      //                       ).colorScheme.onPrimary,
                                      //                     ),
                                      //                   ),
                                      //                 ),
                                      //                 title: Text(
                                      //                   location.place?['name'] ??
                                      //                       location.location?['name'],
                                      //                   style: const TextStyle(
                                      //                     fontWeight: FontWeight.bold,
                                      //                   ),
                                      //                 ),
                                      //                 subtitle: Text(
                                      //                   location.formattedTime,
                                      //                 ),
                                      //                 onTap: () {
                                      //                   showDialog(
                                      //                     context: context,
                                      //                     builder: (BuildContext detailContext) {
                                      //                       return AlertDialog(
                                      //                         title: const Text(
                                      //                           '상세 정보',
                                      //                         ),
                                      //                         content: SingleChildScrollView(
                                      //                           child: Column(
                                      //                             crossAxisAlignment:
                                      //                             CrossAxisAlignment
                                      //                                 .start,
                                      //                             mainAxisSize:
                                      //                             MainAxisSize.min,
                                      //                             children: [
                                      //                               if (location
                                      //                                   .place !=
                                      //                                   null) ...[
                                      //                                 const Text(
                                      //                                   '장소 정보:',
                                      //                                   style: TextStyle(
                                      //                                     fontWeight:
                                      //                                     FontWeight
                                      //                                         .bold,
                                      //                                   ),
                                      //                                 ),
                                      //                                 Text(
                                      //                                   const JsonEncoder.withIndent(
                                      //                                     '  ',
                                      //                                   ).convert(
                                      //                                     location
                                      //                                         .place,
                                      //                                   ),
                                      //                                 ),
                                      //                                 const SizedBox(
                                      //                                   height: 16,
                                      //                                 ),
                                      //                               ],
                                      //                               if (location
                                      //                                   .location !=
                                      //                                   null) ...[
                                      //                                 const Text(
                                      //                                   '위치 정보:',
                                      //                                   style: TextStyle(
                                      //                                     fontWeight:
                                      //                                     FontWeight
                                      //                                         .bold,
                                      //                                   ),
                                      //                                 ),
                                      //                                 Text(
                                      //                                   const JsonEncoder.withIndent(
                                      //                                     '  ',
                                      //                                   ).convert(
                                      //                                     location
                                      //                                         .location,
                                      //                                   ),
                                      //                                 ),
                                      //                                 const SizedBox(
                                      //                                   height: 16,
                                      //                                 ),
                                      //                               ],
                                      //                               const Text(
                                      //                                 '시간:',
                                      //                                 style: TextStyle(
                                      //                                   fontWeight:
                                      //                                   FontWeight
                                      //                                       .bold,
                                      //                                 ),
                                      //                               ),
                                      //                               Text(
                                      //                                 location
                                      //                                     .formattedTime,
                                      //                               ),
                                      //                             ],
                                      //                           ),
                                      //                         ),
                                      //                         actions: [
                                      //                           TextButton(
                                      //                             onPressed: () =>
                                      //                                 Navigator.pop(
                                      //                                   detailContext,
                                      //                                 ),
                                      //                             child: const Text(
                                      //                               '닫기',
                                      //                             ),
                                      //                           ),
                                      //                         ],
                                      //                       );
                                      //                     },
                                      //                   );
                                      //                 },
                                      //               );
                                      //             },
                                      //           ),
                                      //         ),
                                      //         actions: [
                                      //           TextButton(
                                      //             onPressed: () =>
                                      //                 Navigator.pop(dialogContext),
                                      //             child: const Text('닫기'),
                                      //           ),
                                      //         ],
                                      //       );
                                      //     },
                                      //   );
                                      // }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.question_answer),
                                    title: const Text('자주 하는 질문'),
                                    onTap: () {
                                      context.read<HomeBloc>().add(
                                        ShowFrequentQuestions(),
                                      );
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showFrequentQuestions(List<FrequentQuestion> questions) {
    String selectedCategory = '위치';
    List<FrequentQuestion> frequentQuestions = questions;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '자주 하는 질문',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          items: const [
                            DropdownMenuItem(value: '위치', child: Text('위치')),
                          ],
                          onChanged: (String? value) {
                            if (value != null) {
                              setModalState(() {
                                selectedCategory = value;
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.add), onPressed: () {}),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: frequentQuestions.length,
                      itemBuilder: (context, index) {
                        final question = frequentQuestions[index];
                        return ListTile(
                          title: Text(question.question),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditQuestionDialog(
                                  context,
                                  index,
                                  question,
                                  selectedCategory,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () =>
                                    _showDeleteQuestionDialog(context, index),
                              ),
                            ],
                          ),
                          onTap: () {
                            _messageController.text = question.question;
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteQuestionDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('질문 삭제'),
          content: const Text('이 질문을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                context.read<HomeBloc>().add(HomeEvent.deleteQuestion(index));
                Navigator.pop(context);
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _showEditQuestionDialog(
    BuildContext context,
    int index,
    FrequentQuestion question,
    String selectedCategory,
  ) {
    final TextEditingController questionController = TextEditingController(
      text: question.question,
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('질문 수정'),
          content: TextField(
            controller: questionController,
            decoration: const InputDecoration(hintText: '질문을 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                if (questionController.text.isNotEmpty) {
                  context.read<HomeBloc>().add(
                    UpdateQuestion(
                      index,
                      questionController.text,
                      selectedCategory,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('수정'),
            ),
          ],
        );
      },
    );
  }

  void _showResetConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('대화 초기화'),
          content: const Text('이전 대화 내용과 위치 히스토리가 모두 삭제됩니다. 계속하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<HomeBloc>().add(const ResetConversation());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('대화 내용이 초기화되었습니다')),
                );
              },
              child: const Text('초기화'),
            ),
          ],
        );
      },
    );
  }
}
