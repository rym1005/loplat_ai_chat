import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:common_utils_services/models/message.dart';
import '../../../models/frequent_question.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default([]) List<Message> messages,
    @Default(false) bool isAiResponding,
    @Default(false) bool isLoading,
    @Default(false) bool isShowingFrequentQuestions,
    String? errorMessage,
    @Default([]) List<FrequentQuestion> frequentQuestions,
    @Default('위치') String selectedCategory,
    String? currentAiResponse,
  }) = _HomeState;
}
