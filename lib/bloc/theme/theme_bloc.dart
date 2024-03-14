import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huntfishai/bloc/theme/theme_state.dart';

class ThemeBloc extends Cubit<ThemeState?> {
  ThemeBloc() : super(null);

  void changeTheme() => emit(ChangeTheme());
}
