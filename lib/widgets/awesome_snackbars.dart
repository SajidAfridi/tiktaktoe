import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

SnackBar getMaterialBanner(String message,contentType){
  final materialBanner = SnackBar(
    elevation: 1,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    duration: const Duration(seconds: 2),
    content: AwesomeSnackbarContent(
      title: 'Oh No',
      message:
      'You will be navigated back to the home screen',

      /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
      contentType: contentType,
      // to configure for material banner
      inMaterialBanner: true,
    ),
  );
  return materialBanner;
}



