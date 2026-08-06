part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class IsMusicPlayerOpened extends HomeState {
  final FileElement? fileElement;
  IsMusicPlayerOpened({required this.fileElement});
}

final class AwqafTestPageOpened extends HomeState {
  final String? date;
  AwqafTestPageOpened({required this.date});
}

final class LocalTestPageOpened extends HomeState {
  LocalTestPageOpened();
}

final class CourseTestPageOpened extends HomeState {
  CourseTestPageOpened();
}

final class GradesPageOpened extends HomeState {
  GradesPageOpened();
}

final class RecallsPageOpened extends HomeState {
  RecallsPageOpened();
}

final class DailyTrackPageOpened extends HomeState {
  DailyTrackPageOpened();
}

final class BookAudioPageOpened extends HomeState {
  BookAudioPageOpened();
}

final class VideoPageOpened extends HomeState {
  VideoPageOpened();
}

final class AboutInstitutePageOpened extends HomeState {
  AboutInstitutePageOpened();
}

final class DonationPageOpened extends HomeState {
  DonationPageOpened();
}

final class PersonalPageOpened extends HomeState {
  PersonalPageOpened();
}

final class StudentRankingPageOpened extends HomeState {
  StudentRankingPageOpened();
}

final class MainPageRefreshed extends HomeState {
  MainPageRefreshed();
}
