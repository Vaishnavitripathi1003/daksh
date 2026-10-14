import 'package:flutter/cupertino.dart';

class GlobalClass {
  static final ValueNotifier<String> selectedMemberNotifier = ValueNotifier('');

  static String get selected_member => selectedMemberNotifier.value;
  static set selected_member(String v) => selectedMemberNotifier.value = v;
  static final ValueNotifier<String> selectedMemberIdNotifier = ValueNotifier('');

  static String get selected_member_Id => selectedMemberIdNotifier.value;
  static set selected_member_Id(String v) => selectedMemberIdNotifier.value = v;

  static void reset() {
    selectedMemberNotifier.value = '';
    selectedMemberIdNotifier.value = '';
  }
}