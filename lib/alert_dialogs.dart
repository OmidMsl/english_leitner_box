//part of commons;

import 'package:flutter/material.dart';

/// Private class __AlertDialog
/// cannot use
class __AlertDialog extends StatefulWidget {
  static const SUCCESS = Color(0xff008577);
  static const WARNING = Color(0xffFF8C00);
  static const ERROR = Color(0xffc0392b);
  static const INFO = Color(0xff3c3f41);

  static const SUCCESS_ICON = 1;
  static const ERROR_ICON = 2;
  static const WARNING_ICON = 3;
  static const INFO_ICON = 4;
  static const HELP_ICON = 5;
  static const DELETE_ICON = 6;
  static const RECEIPT_ICON = 7;

  final Color color;
  final String title, message, positiveText, negativeText, neutralText;
  final Function positiveAction, negativeAction, neutralAction;
  final bool showNeutralButton, showTextField;
  final int icon;
  final bool confirm;
  final TextAlign textAlign;
  final TextEditingController inputTextController;
  bool validReason;

  __AlertDialog({
    @required this.color,
    @required this.title,
    @required this.message,
    this.showNeutralButton,
    this.neutralText,
    this.neutralAction,
    this.positiveText,
    this.positiveAction,
    this.negativeText,
    this.negativeAction,
    this.icon,
    this.confirm,
    this.textAlign,
    this.showTextField,
    this.inputTextController,
    this.validReason,
  });

  @override
  __AlertDialogState createState() => __AlertDialogState();
}

class __AlertDialogState extends State<__AlertDialog> {
  bool _confirmDeleteAction = false, _enableTextField = false;

  final successIcon = Icon(
    Icons.check,
    size: 64,
    color: Colors.white,
  );

  final errorIcon = Icon(
    Icons.close,
    size: 64,
    color: Colors.white,
  );

  final warningIcon = Icon(
    Icons.warning,
    size: 64,
    color: Colors.white,
  );

  final infoIcon = Icon(
    Icons.info_outline,
    size: 64,
    color: Colors.white,
  );

  final confirmIcon = Icon(
    Icons.help_outline,
    size: 64,
    color: Colors.white,
  );

  final deleteIcon = Icon(
    Icons.delete_outline,
    size: 64,
    color: Colors.white,
  );

  final receiptIcon = Icon(
    Icons.receipt,
    size: 64,
    color: Colors.white,
  );

  var _dialogIcon;

  @override
  void initState() {
    super.initState();
    _dialogIcon = confirmIcon;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: _dialogContent(context),
    );
  }

  _positiveActionPerform() {
    if (widget.confirm) {
      if (_confirmDeleteAction) {
        Navigator.of(context).pop(); // To close the dialog
        widget.positiveAction();
      }
    } else {
      Navigator.of(context).pop(); // To close the dialog
      widget.positiveAction();
    }
  }

  _getPositiveButtonColor() {
    var color = Colors.black;
    if (widget.confirm) {
      if (_confirmDeleteAction && widget.validReason) {
        if (widget.showTextField) {
          color = Colors.blue[900];
        } else {
          color = Colors.red;
        }
      } else {
        color = Colors.grey;
      }
    } else {
      color = Colors.black;
    }
    return color;
  }

  _positiveButton(BuildContext context) {
    if (widget.positiveText != null && widget.positiveAction != null) {
      return FlatButton(
        onPressed: _positiveActionPerform,
        child: Text(
          widget.positiveText,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: "Homa",
            color: Color(0xff00003f), //_getPositiveButtonColor(),
          ),
        ),
      );
    }
    return SizedBox();
  }

  _negativeButton(BuildContext context) {
    if (widget.negativeText != null && widget.negativeAction != null) {
      return FlatButton(
        onPressed: () {
          Navigator.of(context).pop(); // To close the dialog
          widget.negativeAction();
        },
        child: Text(widget.negativeText, style: TextStyle(fontFamily: 'Homa'),),
      );
    }
    return SizedBox();
  }

  _dialogContent(BuildContext context) {
    _dialogIcon = confirmIcon;

    switch (widget.icon) {
      case __AlertDialog.SUCCESS_ICON:
        _dialogIcon = successIcon;
        break;
      case __AlertDialog.ERROR_ICON:
        _dialogIcon = errorIcon;
        break;
      case __AlertDialog.WARNING_ICON:
        _dialogIcon = warningIcon;
        break;
      case __AlertDialog.INFO_ICON:
        _dialogIcon = infoIcon;
        break;
      case __AlertDialog.HELP_ICON:
        _dialogIcon = confirmIcon;
        break;
      case __AlertDialog.DELETE_ICON:
        _dialogIcon = deleteIcon;
        break;
    }

    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: 45.0 + 16.0,
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          margin: EdgeInsets.only(top: 55.0),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: "Homa",
                    fontWeight: FontWeight.w700,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 16.0),
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.message,
                        textAlign: widget.textAlign == null
                            ? TextAlign.center
                            : widget.textAlign,
                        style: TextStyle(
                          fontFamily: "Vazir",
                          fontSize: 14.0,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                if (widget.confirm)
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: _enableTextField,
                        onChanged: (value) {
                          setState(() {
                            _enableTextField = value;
                          });
                        },
                      ),
                      Text("تغیر نام"),
                    ],
                  ),
                Visibility(
                  visible:
                      widget.showTextField == null ? false : widget.showTextField,
                  child: TextField(
                    enabled: _enableTextField,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: "نام جدید"),
                    maxLines: 1,
                    onChanged: (value) {
                      setState(() {
                        _confirmDeleteAction = value.trim().isNotEmpty;
                      });
                    },
                    controller: widget.inputTextController,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        _negativeButton(context),
                        _positiveButton(context),
                        widget.showNeutralButton
                            ? FlatButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // To close the dialog
                                  widget.neutralAction();
                                },
                                child: Text(widget.neutralText,
                                    style: TextStyle(
                                        fontFamily: "Vazir",
                                        color: Colors.red[900])),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16.0,
          right: 16.0,
          child: CircleAvatar(
            backgroundColor: widget.color,
            radius: 55.0,
            child: widget.icon == 0 ? Text("") : _dialogIcon,
          ),
        ),
      ],
    );
  }
}

/// Generic dialog function
dialog(
  BuildContext context,
  Color color,
  String title,
  String message,
  bool showNeutralButton,
  bool closeOnBackPress, {
  String neutralText,
  Function neutralAction,
  String positiveText,
  Function positiveAction,
  String negativeText,
  Function negativeAction,
  icon = 0,
  confirm = false,
  textAlign: TextAlign.center,
  TextEditingController inputTextController,
  bool validReason,
  bool showTextField,
}) {
  return showDialog(
    barrierDismissible: closeOnBackPress,
    context: context,
    builder: (BuildContext context) => WillPopScope(
      onWillPop: () async => closeOnBackPress,
      child: __AlertDialog(
        color: color,
        title: title,
        message: message,
        showNeutralButton: showNeutralButton,
        neutralText: neutralText,
        neutralAction: neutralAction,
        positiveText: positiveText,
        positiveAction: positiveAction,
        negativeText: negativeText,
        negativeAction: negativeAction,
        icon: icon,
        confirm: confirm,
        textAlign: textAlign,
        inputTextController: inputTextController,
        validReason: validReason,
        showTextField: showTextField,
      ),
    ),
  );
}

/// Success dialog
successDialog(
  BuildContext context,
  String message, {
  showNeutralButton = true,
  String positiveText,
  Function positiveAction,
  String negativeText,
  Function negativeAction,
  String neutralText = "Okay",
  Function neutralAction,
  title = "Success",
  closeOnBackPress = true,
  icon = __AlertDialog.SUCCESS_ICON,
  textAlign: TextAlign.center,
}) {
  return dialog(
    context,
    __AlertDialog.SUCCESS,
    title,
    message,
    showNeutralButton,
    closeOnBackPress,
    neutralText: neutralText,
    neutralAction: neutralAction == null ? () {} : neutralAction,
    positiveText: positiveText,
    positiveAction: positiveAction,
    negativeText: negativeText,
    negativeAction: negativeAction,
    icon: icon,
    textAlign: textAlign,
  );
}

/// Error Dialog
errorDialog(
  BuildContext context,
  String message, {
  showNeutralButton = true,
  String positiveText,
  Function positiveAction,
  String negativeText,
  Function negativeAction,
  String neutralText = "Okay",
  Function neutralAction,
  title = "Error",
  closeOnBackPress = false,
  icon = __AlertDialog.ERROR_ICON,
  textAlign: TextAlign.center,
}) {
  return dialog(
    context,
    __AlertDialog.ERROR,
    title,
    message,
    showNeutralButton,
    closeOnBackPress,
    neutralText: neutralText,
    neutralAction: neutralAction == null ? () {} : neutralAction,
    positiveText: positiveText,
    positiveAction: positiveAction,
    negativeText: negativeText,
    negativeAction: negativeAction,
    icon: icon,
    textAlign: textAlign,
  );
}

/// Warning Dialog
warningDialog(
  BuildContext context,
  String message, {
  showNeutralButton = true,
  String positiveText,
  Function positiveAction,
  String negativeText,
  Function negativeAction,
  String neutralText = "Okay",
  Function neutralAction,
  title = "Warning",
  closeOnBackPress = false,
  icon = __AlertDialog.WARNING_ICON,
  textAlign: TextAlign.center,
}) {
  return dialog(
    context,
    __AlertDialog.WARNING,
    title,
    message,
    showNeutralButton,
    closeOnBackPress,
    neutralText: neutralText,
    neutralAction: neutralAction == null ? () {} : neutralAction,
    positiveText: positiveText,
    positiveAction: positiveAction,
    negativeText: negativeText,
    negativeAction: negativeAction,
    icon: icon,
    textAlign: textAlign,
  );
}

/// Info Dialog
infoDialog(
  BuildContext context,
  String message, {
  showNeutralButton = true,
  String positiveText,
  Function positiveAction,
  String negativeText,
  Function negativeAction,
  String neutralText = "Okay",
  Function neutralAction,
  title = "Info",
  closeOnBackPress = false,
  icon = __AlertDialog.INFO_ICON,
  textAlign: TextAlign.center,
}) {
  return dialog(
    context,
    __AlertDialog.INFO,
    title,
    message,
    showNeutralButton,
    closeOnBackPress,
    neutralText: neutralText,
    neutralAction: neutralAction == null ? () {} : neutralAction,
    positiveText: positiveText,
    positiveAction: positiveAction,
    negativeText: negativeText,
    negativeAction: negativeAction,
    icon: icon,
    textAlign: textAlign,
  );
}

/// Confirmation Dialog
confirmationDialog(
  BuildContext context,
  String message, {
  showNeutralButton = true,
  String positiveText,
  Function positiveAction,
  String negativeText,
  Function negativeAction,
  String neutralText = "Cancel",
  Function neutralAction,
  title = "Confirmation?",
  closeOnBackPress = false,
  icon = __AlertDialog.HELP_ICON,
  confirm: true,
  textAlign: TextAlign.center,
}) {
  return dialog(
    context,
    __AlertDialog.WARNING,
    title,
    message,
    showNeutralButton,
    closeOnBackPress,
    neutralText: neutralText,
    neutralAction: neutralAction == null ? () {} : neutralAction,
    positiveText: positiveText,
    positiveAction: positiveAction,
    negativeText: negativeText,
    negativeAction: negativeAction,
    icon: icon,
    confirm: confirm,
    textAlign: textAlign,
  );
}

sameNameDialog(
  BuildContext context,
  String message, {
  showNeutralButton = true,
  String positiveText = 'تغیر نام',
  Function positiveAction,
  String negativeText = 'ادغام',
  Function negativeAction,
  String neutralText = "لغو",
  Function neutralAction,
  title = "Confirmation?",
  closeOnBackPress = false,
  icon = __AlertDialog.HELP_ICON,
  confirm: true,
  textAlign: TextAlign.center,
  TextEditingController inputTextController,
  bool validReason,
}) {
  return dialog(
    context,
    __AlertDialog.WARNING,
    title,
    message,
    showNeutralButton,
    closeOnBackPress,
    neutralText: neutralText,
    neutralAction: neutralAction == null ? () {} : neutralAction,
    positiveText: positiveText,
    positiveAction: positiveAction,
    negativeText: negativeText,
    negativeAction: negativeAction,
    icon: icon,
    confirm: confirm,
    textAlign: textAlign,
    inputTextController: inputTextController,
    validReason: validReason,
    showTextField: true,
  );
}

deleteDialog(
  BuildContext context,
  String message, {
  showNeutralButton = true,
  String positiveText = 'حذف',
  Function positiveAction,
  String negativeText,
  Function negativeAction,
  String neutralText = "لغو",
  Function neutralAction,
  title = "حذف شود؟",
  closeOnBackPress = true,
  icon = __AlertDialog.DELETE_ICON,
  confirm: false,
  textAlign: TextAlign.center,
}) {
  return dialog(
    context,
    __AlertDialog.ERROR,
    title,
    message,
    showNeutralButton,
    closeOnBackPress,
    neutralText: neutralText,
    neutralAction: neutralAction == null ? () {} : neutralAction,
    positiveText: positiveText,
    positiveAction: positiveAction,
    negativeText: negativeText,
    negativeAction: negativeAction,
    icon: icon,
    confirm: confirm,
    textAlign: textAlign,
  );
}

receiptDialog(
  BuildContext context,
  String message, {
  showNeutralButton = false,
  String positiveText = 'دوربین',
  Function positiveAction,
  String negativeText = 'گالری',
  Function negativeAction,
  String neutralText = "لغو",
  Function neutralAction,
  title = ".انتخاب کنید",
  closeOnBackPress = true,
  icon = __AlertDialog.RECEIPT_ICON,
  confirm: false,
  textAlign: TextAlign.center,
}) {
  return dialog(
    context,
    __AlertDialog.ERROR,
    title,
    message,
    showNeutralButton,
    closeOnBackPress,
    neutralText: neutralText,
    neutralAction: neutralAction == null ? () {} : neutralAction,
    positiveText: positiveText,
    positiveAction: positiveAction,
    negativeText: negativeText,
    negativeAction: negativeAction,
    icon: icon,
    confirm: confirm,
    textAlign: textAlign,
  );
}

/// Waiting Dialog
waitDialog(BuildContext context,
    {message = "Please wait...", Duration duration}) {
  var dialog = Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    elevation: 0.0,
    backgroundColor: Colors.white,
    child: Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              margin: EdgeInsets.all(8), child: CircularProgressIndicator()),
          Text(message),
        ],
      ),
    ),
  );

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) => WillPopScope(onWillPop: () async => false, child: dialog),
  );

  if (duration != null) {
    Future.delayed(
      duration,
      () {
        Navigator.of(context).pop();
      },
    );
  }
}
