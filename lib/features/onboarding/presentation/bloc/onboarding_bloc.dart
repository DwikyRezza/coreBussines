// ============================================================
// FEATURE: Onboarding — BLoC
// lib/features/onboarding/presentation/bloc/onboarding_bloc.dart
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/onboarding_slide.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc()
      : super(
          OnboardingState(slides: _defaultSlides),
        ) {
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingNextPage>(_onNextPage);
    on<OnboardingPreviousPage>(_onPreviousPage);
    on<OnboardingCompleted>(_onCompleted);
  }

  static final List<OnboardingSlide> _defaultSlides = [
    const OnboardingSlide(
      title: 'Catat Keuangan\nBisnis\nDengan Mudah',
      subtitle:
          'Pantau seluruh arus kas, kelola transaksi, dan lihat performa bisnis dalam satu dashboard cerdas.',
      illustration: 'dashboard_mock',
      accentTag: '',
    ),
    const OnboardingSlide(
      title: 'Pantau Performa Bisnis\nSecara Real-Time',
      subtitle:
          'Dapatkan visibilitas penuh atas arus kas dan performa operasional Anda dengan dashboard analitik cerdas kami.',
      illustration: 'chart_mock',
      accentTag: '',
    ),
    const OnboardingSlide(
      title: 'Atur Jadwal dan\nAktivitas Bisnis',
      subtitle:
          'Pantau seluruh jadwal pengiriman dan terima pengingat otomatis agar operasional bisnis berjalan lancar dan efisien.',
      illustration: 'calendar_mock',
      accentTag: '',
    ),
  ];

  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(currentPage: event.pageIndex));
  }

  void _onNextPage(
    OnboardingNextPage event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.isLastPage) {
      emit(state.copyWith(isCompleted: true));
      return;
    }
    emit(state.copyWith(currentPage: state.currentPage + 1));
  }

  void _onPreviousPage(
    OnboardingPreviousPage event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.currentPage > 0) {
      emit(state.copyWith(currentPage: state.currentPage - 1));
    }
  }

  void _onCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(isCompleted: true));
  }
}
