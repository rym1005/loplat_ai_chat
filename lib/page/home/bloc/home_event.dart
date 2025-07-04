import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../models/frequent_question.dart';

part 'home_event.freezed.dart';

@freezed
class HomeEvent with _$HomeEvent {
  const factory HomeEvent.init(BuildContext context) = Init;
  const factory HomeEvent.load() = LoadHomeData;
  const factory HomeEvent.sendMessage(String message) = SendMessage;
  const factory HomeEvent.cancelAiResponse() = CancelAiResponse;
  const factory HomeEvent.resetConversation() = ResetConversation;
  const factory HomeEvent.showFrequentQuestions() = ShowFrequentQuestions;
  const factory HomeEvent.loadFrequentQuestions(String category) =
      LoadFrequentQuestions;
  const factory HomeEvent.addQuestion(String question, String category) =
      AddQuestion;
  const factory HomeEvent.updateQuestion(
    int index,
    String question,
    String category,
  ) = UpdateQuestion;
  const factory HomeEvent.deleteQuestion(int index) = DeleteQuestion;
  const factory HomeEvent.showSettings() = ShowSettings;
  const factory HomeEvent.copyToClipboard(String message) = CopyToClipboard;
  const factory HomeEvent.showLocationHistory() = ShowLocationHistory;
  const factory HomeEvent.hideLocationHistory() = HideLocationHistory;
  const factory HomeEvent.checkCurrentLocation() = CheckCurrentLocation;
  const factory HomeEvent.aiResponseStreamChanged(String chunk) =
      AiResponseStreamChanged;
  const factory HomeEvent.aiResponseStreamDone() = AiResponseStreamDone;
  const factory HomeEvent.aiResponseStreamError(dynamic error) =
      AiResponseStreamError;
}
