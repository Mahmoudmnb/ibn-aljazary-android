part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

class OpenMusicPlayer extends HomeEvent {
  final FileElement? fileElement;
  OpenMusicPlayer({required this.fileElement});
}

class InitEvent extends HomeEvent {
  InitEvent();
}

class OpenAwqafTestPage extends HomeEvent {
  final String date;
  OpenAwqafTestPage({required this.date});
}

class OpenLocalTestPage extends HomeEvent {
  OpenLocalTestPage();
}

class OpenCourseTestPage extends HomeEvent {
  OpenCourseTestPage();
}

class OpenGradesPage extends HomeEvent {
  OpenGradesPage();
}

class OpenRecallsPage extends HomeEvent {
  OpenRecallsPage();
}

class OpenDailyTrackPage extends HomeEvent {
  OpenDailyTrackPage();
}

class OpenBookAudioPage extends HomeEvent {
  OpenBookAudioPage();
}

class OpenVideosPage extends HomeEvent {
  OpenVideosPage();
}

class OpenAboutInstitutePage extends HomeEvent {
  OpenAboutInstitutePage();
}

class OpenDonationPage extends HomeEvent {
  OpenDonationPage();
}

class OpenPersonalPage extends HomeEvent {
  OpenPersonalPage();
}

class OpenStudentRankingPage extends HomeEvent {
  OpenStudentRankingPage();
}

class RefreshMainPage extends HomeEvent {
  RefreshMainPage();
}
