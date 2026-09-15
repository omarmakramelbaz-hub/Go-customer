import 'dart:developer';

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
    log('Saved Language ==> ${await GlobalTranslations.getPreferredLanguage()}');

    String? lang;

    if (await GlobalTranslations.getPreferredLanguage() == '') {
      lang = 'en';
      await GlobalTranslations.setNewLanguage(lang);
      updateLang(lang);
      log('First getShared Lang............. $lang');
    } else {
      lang = await GlobalTranslations.getPreferredLanguage();
      updateLang(lang);
      await GlobalTranslations.setNewLanguage(lang);
      log('Second getShared Lang............. $lang');
    }
  }
}

MainAppBloc mainAppBloc = MainAppBloc();
