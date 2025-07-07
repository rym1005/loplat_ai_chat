import 'dart:async';
import 'package:common_utils_services/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Message;
import 'package:hive/hive.dart';
import 'package:common_utils_services/models/location_history.dart';
import 'package:common_utils_services/models/message.dart';
import 'package:common_utils_services/services/ai_services.dart';
import '../../../services/frequent_question_service.dart';
import 'package:common_utils_services/utils/location_utils.dart';
import '../../../services/settings_service.dart';
import '../../../utils/permission/permission_utils.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  late Box<Message> _messageBox;
  final LocationHistoryManager _locationHistoryManager =
      LocationHistoryManager();
  final FrequentQuestionService frequentQuestionService =
      FrequentQuestionService();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late NotificationService? _notificationService;
  StreamSubscription? _aiResponseSubscription;

  BuildContext? _context;

  HomeBloc() : super(const HomeState()) {
    on<Init>(_onInit);
    on<LoadHomeData>(_onLoad);
    on<SendMessage>(_onSendMessage);
    on<CancelAiResponse>(_onCancelAiResponse);
    on<ResetConversation>(_onResetConversation);
    on<LoadFrequentQuestions>(_onLoadFrequentQuestions);
    on<AddQuestion>(_onAddQuestion);
    on<UpdateQuestion>(_onUpdateQuestion);
    on<DeleteQuestion>(_onDeleteQuestion);
    on<CopyToClipboard>(_onCopyToClipboard);
    on<ShowLocationHistory>(_onShowLocationHistory);
    on<CheckCurrentLocation>(_onCheckCurrentLocation);
    on<AiResponseStreamChanged>(_onAiResponseStreamChanged);
    on<AiResponseStreamDone>(_onAiResponseStreamDone);
    on<AiResponseStreamError>(_onAiResponseStreamError);
    on<ShowFrequentQuestions>(_onShowFrequentQuestions);
    on<HideLocationHistory>(_onHideLocationHistory);
  }

  Future<void> _onInit(Init event, Emitter<HomeState> emit) async {
    _context = event.context;
    await _initHive(emit);
    if (_context != null && _context!.mounted) {
      await PermissionUtils.checkAndRequestPermission(_context!);
    }
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    initSubscription();
  }

  void initSubscription() {
    _locationHistoryManager.initialize(10, (location) {
      print("rymins : $location");
      // chatPush(location);
    });
  }

  Future<void> _initHive(Emitter<HomeState> emit) async {
    try {
      _notificationService = NotificationService();

      Hive.registerAdapter(MessageAdapter());
      Hive.registerAdapter(LocationHistoryAdapter());
      _messageBox = await Hive.openBox<Message>('messages');

      await frequentQuestionService.initialize();
      await _onLoadFrequentQuestions(
        LoadFrequentQuestions(state.selectedCategory),
        emit,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: '초기화 중 오류가 발생했습니다.'));
    }
    emit(state.copyWith(messages: _messageBox.values.toList()));
    add(LoadHomeData());
  }

  String _summarizePlengiResponse(String response) {
    return response.split('\n')[0];
  }

  Future<void> _onHistorySummary() async {
    await _locationHistoryManager.initialize(10, (location) {
      Future.microtask(() async {
        final data = await AIServices.instance.getAIResponse(location, []);
        final summary = _summarizePlengiResponse(data);
        print("rymins summary : $summary");
        await _notificationService?.showNotification(
          title: summary,
          body: '새로운 위치 정보가 있습니다.',
        );
      });
    });
  }

  Future<void> _onLoad(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      emit(
        state.copyWith(isLoading: false, messages: _messageBox.values.toList()),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: "데이터를 불러오지 못했습니다"));
      emit(state.copyWith(errorMessage: null));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<HomeState> emit,
  ) async {
    if (event.message.isEmpty) return;

    final userMessage = Message(role: 'user', content: event.message);
    final newMessages = List<Message>.from(state.messages)..add(userMessage);
    await _messageBox.add(userMessage);

    emit(state.copyWith(messages: newMessages, isAiResponding: true));

    final aiWaitingMessage = Message(role: 'assistant', content: '');
    final messagesWithWaiting = List<Message>.from(newMessages)
      ..add(aiWaitingMessage);
    await _messageBox.add(aiWaitingMessage);
    emit(state.copyWith(messages: messagesWithWaiting));

    _aiResponseSubscription?.cancel();
    emit(state.copyWith(currentAiResponse: ''));

    try {
      String locationContext = '';
      locationContext = _locationHistoryManager.locationHistory.firstOrNull.toString();

      _aiResponseSubscription = AIServices.instance
          .getAIResponseStream(
            SettingsService().getPrompt(),
            '$locationContext\n${event.message}',
            state.messages,
          )
          .listen(
            (chunk) => add(AiResponseStreamChanged(chunk)),
            onDone: () => add(const AiResponseStreamDone()),
            onError: (error) => add(AiResponseStreamError(error)),
          );
    } catch (e) {
      add(AiResponseStreamError(e));
    }
  }

  void _onAiResponseStreamChanged(
    AiResponseStreamChanged event,
    Emitter<HomeState> emit,
  ) {
    final newResponse = (state.currentAiResponse ?? '') + event.chunk;
    final updatedMessages = List<Message>.from(state.messages);
    updatedMessages.last = Message(role: 'assistant', content: newResponse);
    _messageBox.putAt(_messageBox.length - 1, updatedMessages.last);
    emit(
      state.copyWith(currentAiResponse: newResponse, messages: updatedMessages),
    );
  }

  void _onAiResponseStreamDone(
    AiResponseStreamDone event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(isAiResponding: false));
  }

  void _onAiResponseStreamError(
    AiResponseStreamError event,
    Emitter<HomeState> emit,
  ) {
    print('AI 응답 오류: ${event.error}');
    final updatedMessages = List<Message>.from(state.messages);
    updatedMessages.last = Message(
      role: 'assistant',
      content: '죄송합니다. 응답을 생성하는 중에 오류가 발생했습니다.',
    );
    _messageBox.putAt(_messageBox.length - 1, updatedMessages.last);
    emit(state.copyWith(messages: updatedMessages, isAiResponding: false));
  }

  void _onCancelAiResponse(
    CancelAiResponse event,
    Emitter<HomeState> emit,
  ) async {
    _aiResponseSubscription?.cancel();
    emit(state.copyWith(isAiResponding: false));
    if (state.messages.isNotEmpty) {
      await _messageBox.deleteAt(state.messages.length - 1);
      final newMessages = List<Message>.from(state.messages)..removeLast();
      emit(state.copyWith(messages: newMessages));
    }
  }

  void _onResetConversation(
    ResetConversation event,
    Emitter<HomeState> emit,
  ) async {
    await _messageBox.clear();
    _locationHistoryManager.clear();
    emit(state.copyWith(messages: []));
  }

  Future<void> _onLoadFrequentQuestions(
    LoadFrequentQuestions event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedCategory: event.category,
        frequentQuestions: frequentQuestionService.getQuestions(),
      ),
    );
  }

  Future<void> _onAddQuestion(
    AddQuestion event,
    Emitter<HomeState> emit,
  ) async {
    await frequentQuestionService.addQuestion(event.question, event.category);
    add(LoadFrequentQuestions(event.category));
  }

  Future<void> _onUpdateQuestion(
    UpdateQuestion event,
    Emitter<HomeState> emit,
  ) async {
    await frequentQuestionService.updateQuestion(
      event.index,
      event.question,
      event.category,
    );
    add(LoadFrequentQuestions(event.category));
  }

  Future<void> _onDeleteQuestion(
    DeleteQuestion event,
    Emitter<HomeState> emit,
  ) async {
    await frequentQuestionService.deleteQuestion(event.index);
    add(LoadFrequentQuestions(state.selectedCategory));
  }

  void _onCopyToClipboard(CopyToClipboard event, Emitter<HomeState> emit) {
    // This should be handled in the UI layer
  }

  void _onShowLocationHistory(
    ShowLocationHistory event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(isLoading: true));
    try {
      print("rymins ${_locationHistoryManager.locationHistory.length}");
      emit(
        state.copyWith(
          isLoading: false,
          isShowingLocationHistory: true,
          locationHistory: _locationHistoryManager.locationHistory,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: "데이터를 불러오지 못했습니다$e"));
    }
  }

  void _onHideLocationHistory(
    HideLocationHistory event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(isShowingLocationHistory: false));
  }

  Future<void> _onCheckCurrentLocation(
    CheckCurrentLocation event,
    Emitter<HomeState> emit,
  ) async {
    final currentLocation  = await LocationUtils.getCurrentLocation();
    print("rymins currentLocation : $currentLocation");
  }

  Future<void> _onShowFrequentQuestions(
    ShowFrequentQuestions event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final questions = frequentQuestionService.getQuestions();
      emit(
        state.copyWith(
          isLoading: false,
          isShowingFrequentQuestions: true,
          frequentQuestions: questions,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: "데이터를 불러오지 못했습니다"));
    }
  }

  @override
  Future<void> close() {
    _aiResponseSubscription?.cancel();
    _messageBox.close();
    _locationHistoryManager.dispose();
    frequentQuestionService.dispose();
    return super.close();
  }

  void chatPush(String location) async {
    try {
      final chat = await AIServices.instance
          .getAIResponseWithLocation(
            prompt: SettingsService().getPrompt(),
            userlocation: location,
          );
      await _notificationService?.showNotification(title: "Ai-Chat", body: chat);
    } catch (e) {
      print("rymins $e");
    }
  }
}
