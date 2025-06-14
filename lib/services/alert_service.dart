import 'package:chat_app_flutter/services/navigation_service.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AlertService {
  final GetIt _getit = GetIt.instance;
  late NavigationService _navigationService;
  AlertService() {
    _navigationService = _getit.get<NavigationService>();
  }

  void showToast({
    required String text,
    IconData icon = Icons.info,
  }) {
    try {
      DelightToastBar(
          autoDismiss: true,
          position: DelightSnackbarPosition.top,
          builder: (context) {
            return ToastCard(
                leading: Icon(
                  icon,
                  size: 28,
                ),
                title: Text(
                  text,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ));
          }).show(_navigationService.navigatorkey!.currentContext!);
    } catch (e) {
      print(e);
    }
  }
}
