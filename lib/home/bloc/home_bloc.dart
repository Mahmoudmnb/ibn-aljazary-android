import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/file_collection.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeEvent>((event, emit) {
      if (event is OpenMusicPlayer) {
        emit(IsMusicPlayerOpened(fileElement: event.fileElement));
      } else if (event is OpenAwqafTestPage) {
        emit(AwqafTestPageOpened(date: event.date));
      } else if (event is InitEvent) {
        emit(HomeInitial());
      } else if (event is OpenLocalTestPage) {
        emit(LocalTestPageOpened());
      } else if (event is OpenCourseTestPage) {
        emit(CourseTestPageOpened());
      } else if (event is OpenGradesPage) {
        emit(GradesPageOpened());
      } else if (event is OpenRecallsPage) {
        emit(RecallsPageOpened());
      } else if (event is OpenDailyTrackPage) {
        emit(DailyTrackPageOpened());
      } else if (event is OpenBookAudioPage) {
        emit(BookAudioPageOpened());
      } else if (event is OpenVideosPage) {
        emit(VideoPageOpened());
      } else if (event is OpenAboutInstitutePage) {
        emit(AboutInstitutePageOpened());
      } else if (event is OpenDonationPage) {
        emit(DonationPageOpened());
      } else if (event is OpenPersonalPage) {
        emit(PersonalPageOpened());
      } else if (event is OpenStudentRankingPage) {
        emit(StudentRankingPageOpened());
      } else if (state is RefreshMainPage) {
        emit(MainPageRefreshed());
      }
    });
  }
}
