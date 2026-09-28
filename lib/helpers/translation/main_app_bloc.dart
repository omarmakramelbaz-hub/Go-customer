import 'package:rxdart/rxdart.dart';

import 'all_translation.dart';

class MainAppBloc {
  final lang = BehaviorSubject<String>();

  Function(String) get updateLang => lang.sink.add;

  Stream<String> get langStream => lang.stream.asBroadcastStream();

  void dispose() {
    lang.close();
  }

  Future<void> getShared() async {
    await GlobalTranslations.setNewLanguage(
      await GlobalTranslations.getPreferredLanguage(),
      false,
    );
    updateLang(GlobalTranslations.currentLanguage);
  }
}

MainAppBloc mainAppBloc = MainAppBloc();
