import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:vibration/vibration.dart';

typedef PasswordEnteredCallback = void Function(String text);
typedef IsValidCallback = void Function();
typedef CancelCallback = void Function();
typedef KeyboardTapCallback = void Function(String text);

const Duration fadeDuration = Duration(milliseconds: 400);
const Duration animationDuration = Duration(milliseconds: 500);

class PasscodeScreen extends StatefulWidget {
  final String title;
  /// Length of pincode must be at least 4 digits
  final int passwordDigits;
  final Color titleColor;
  final Color backgroundColor;
  final String cancelLocalizedText;
  final Stream<bool> shouldTriggerVerification;
  final Widget bottomWidget;
  final CircleUIConfig circleUIConfig;
  final KeyboardUIConfig keyboardUIConfig;
  /// isValidCallback will be invoked after passcode screen will pop.
  final IsValidCallback isValidCallback;
  final PasswordEnteredCallback passwordEnteredCallback;
  final CancelCallback cancelCallback;
  // display or not cancel button
  final bool shouldShowCancel;

  final bool isSettingMode;

  PasscodeScreen({
    Key key,
    @required this.title,
    this.passwordDigits = 6,
    this.cancelLocalizedText,
    @required this.shouldTriggerVerification,
    this.circleUIConfig,
    this.keyboardUIConfig,
    this.bottomWidget,
    this.titleColor = Colors.white,
    this.backgroundColor,
    @required this.passwordEnteredCallback,
    @required this.isValidCallback,
    this.cancelCallback,
    this.shouldShowCancel = true,
    this.isSettingMode = false,
  }) :  assert(passwordDigits >= 4),
        super(key: key);

  @override
  State<StatefulWidget> createState() => PasscodeScreenState();
}

class PasscodeScreenState extends State<PasscodeScreen>
    with SingleTickerProviderStateMixin {

  StreamSubscription<bool> streamSubscription;
  AnimationController controller;
  Animation<double> animation;

  String entered = '';
  String passcode = '';
  String confirmation = '';

  Color circleFillColor;

  bool showSecondRow = false;

  @override
  initState() {
    super.initState();
    circleFillColor = widget.circleUIConfig.fillColor;
    streamSubscription = widget.shouldTriggerVerification
        .listen((isValid) => _showValidation(isValid));
    controller = AnimationController(
        duration: animationDuration, vsync: this);
    final Animation curve =
        CurvedAnimation(parent: controller, curve: ShakeCurve());
    animation = Tween(begin: 0.0, end: 10.0).animate(curve)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            entered = '';
            controller.value = 0;
            circleFillColor = widget.circleUIConfig.fillColor;
          });
        }
      })
      ..addListener(() {
        setState(() {
          // the animation object’s value is the changed state
        });
      });
  }

  @override
  dispose() {
    super.dispose();
    controller.dispose();
    streamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    showSecondRow = entered.length >= widget.passwordDigits && widget.isSettingMode;
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.black.withOpacity(0.8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: widget.titleColor,
                fontWeight: FontWeight.w300),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, left: 60, right: 60),
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _circlesFirstRow(),
              ),
            ),
            SizedBox(height: 20.0,),
            AnimatedOpacity(
              duration: fadeDuration,
              opacity: showSecondRow? 1.0 : 0.0,
              child: Text(
                'Повторите код доступа',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: widget.titleColor,
                  fontWeight: FontWeight.w300
                ),
              ),
            ),
            AnimatedOpacity(
              duration: fadeDuration,
              opacity: showSecondRow? 1.0 : 0.0,
              child: Container(
                margin: const EdgeInsets.only(top: 20, left: 60, right: 60),
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _circlesSecondRow(),
                ),
              ),
            ),
            SizedBox(height: 60.0,),
            IntrinsicHeight(
              child: Container(
                margin: const EdgeInsets.only(top: 20, left: 40, right: 40),
                child: Keyboard(
                  onCancelTap: _onCancelButtonPressed,
                  onDeleteTap: _onDelete,
                  onKeyboardTap: _keyboardCallback,
                  cancelLocalizedText: widget.cancelLocalizedText,
                  keyboardUIConfig: widget.keyboardUIConfig != null
                      ? widget.keyboardUIConfig
                      : KeyboardUIConfig(),
                ),
              ),
            ),
            widget.bottomWidget != null ? widget.bottomWidget : Container()
          ],
        ),
      ),
    );
  }

  List<Widget> _circlesFirstRow() {
    var list = <Widget>[];
    var config = widget.circleUIConfig != null
        ? widget.circleUIConfig
        : CircleUIConfig(fillColor: circleFillColor, borderColor: circleFillColor);
    config.extraSize = animation.value;
    for (int i = 0; i < widget.passwordDigits; i++) {
      list.add(Circle(
        filled: i < entered.length,
        circleUIConfig: config,
      ));
    }
    return list;
  }

  List<Widget> _circlesSecondRow() {
    var list = <Widget>[];
    var config = widget.circleUIConfig != null
        ? widget.circleUIConfig
        : CircleUIConfig(fillColor: circleFillColor, borderColor: circleFillColor);
    config.extraSize = animation.value;
    for (int i = widget.passwordDigits; i < widget.passwordDigits * 2; i++) {
      list.add(Circle(
        filled: i < entered.length,
        circleUIConfig: config,
      ));
    }
    return list;
  }

  Widget progressIndicator() {
    return CircularProgressIndicator();
  }

  void _onDelete() {
    if (entered.length > 0) {
      setState(() {
        entered = entered.substring(0, entered.length - 1);
      });
    }
  }

  void _onCancelButtonPressed() {
    Navigator.maybePop(context);

    if (widget.cancelCallback != null) {
      widget.cancelCallback();
    }
  }

  void _keyboardCallback(String text) {
    setState(() {
      if (entered.length < 2 * widget.passwordDigits) {
        entered += text;
        if (!widget.isSettingMode && entered.length == widget.passwordDigits) {
          widget.passwordEnteredCallback(entered);
        }
      }
      if (entered.length == 2 * widget.passwordDigits) {
        passcode = entered.substring(0, widget.passwordDigits);
        confirmation = entered.substring(widget.passwordDigits);
        if (passcode == confirmation) {
          widget.passwordEnteredCallback(entered.substring(0, widget.passwordDigits));
        }
        else {
          _showValidation(false);
        }
      }
    });
  }

  @override
  didUpdateWidget(PasscodeScreen old) {
    super.didUpdateWidget(old);
    // in case the stream instance changed, subscribe to the new one
    if (widget.shouldTriggerVerification != old.shouldTriggerVerification) {
      streamSubscription.cancel();
      streamSubscription = widget.shouldTriggerVerification
        .listen((isValid) => _showValidation(isValid));
    }
  }

  void _showValidation(bool isValid) {
    if (isValid) {
      Navigator.maybePop(context).then((pop) => _validationCallback());
    }
    else {
      circleFillColor = widget.circleUIConfig.errorColor;
      controller.forward();
      Vibration.vibrate();
    }
  }

  void _validationCallback() {
    if (widget.isValidCallback != null) {
      widget.isValidCallback();
    }
    else {
      print("Validation callback not found");
    }
  }
}

class CircleUIConfig {
  final Color borderColor;
  final Color fillColor;
  final Color errorColor;
  final double borderWidth;
  final double circleSize;
  double extraSize;

  CircleUIConfig({
    this.extraSize = 0,
    this.borderColor = Colors.white,
    this.borderWidth = 1,
    this.fillColor = Colors.white,
    this.errorColor = Colors.red,
    this.circleSize = 20
  });
}

class Circle extends StatelessWidget {
  final bool filled;
  final CircleUIConfig circleUIConfig;

  Circle({
    Key key,
    this.filled = false,
    @required this.circleUIConfig
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: circleUIConfig.extraSize),
      width: circleUIConfig.circleSize,
      height: circleUIConfig.circleSize,
      decoration: BoxDecoration(
        color: filled ? circleUIConfig.fillColor : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: circleUIConfig.borderColor,
          width: circleUIConfig.borderWidth
        )
      ),
    );
  }
}

class KeyboardUIConfig {
  final double digitSize;
  final double digitBorderWidth;
  final TextStyle digitTextStyle;
  final TextStyle deleteButtonTextStyle;
  final Color primaryColor;
  final Color digitFillColor;
  final EdgeInsetsGeometry keyboardRowMargin;
  final EdgeInsetsGeometry deleteButtonMargin;

  KeyboardUIConfig({
    this.digitSize = 80,
    this.digitBorderWidth = 1,
    this.keyboardRowMargin = const EdgeInsets.only(top: 15),
    this.primaryColor = Colors.white,
    this.digitFillColor = Colors.transparent,
    this.digitTextStyle = const TextStyle(fontSize: 30, color: Colors.white),
    this.deleteButtonMargin = const EdgeInsets.only(right: 25, left: 20, top: 15),
    this.deleteButtonTextStyle = const TextStyle(fontSize: 16, color: Colors.white),
  });
}

class Keyboard extends StatelessWidget {
  final KeyboardUIConfig keyboardUIConfig;
  final GestureTapCallback onDeleteTap;
  final GestureTapCallback onCancelTap;
  final KeyboardTapCallback onKeyboardTap;
  final String cancelLocalizedText;

  Keyboard({
    Key key,
    @required this.keyboardUIConfig,
    @required this.onDeleteTap,
    @required this.onCancelTap,
    @required this.onKeyboardTap,
    this.cancelLocalizedText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _buildKeyboard();

  Widget _buildKeyboard() {
    bool showCancel = false;
    if (cancelLocalizedText != null) showCancel = true;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildKeyboardDigit('1'),
            _buildKeyboardDigit('2'),
            _buildKeyboardDigit('3'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildKeyboardDigit('4'),
            _buildKeyboardDigit('5'),
            _buildKeyboardDigit('6'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildKeyboardDigit('7'),
            _buildKeyboardDigit('8'),
            _buildKeyboardDigit('9'),
          ],
        ),
        Stack(
          children: <Widget>[
            Center(child: _buildKeyboardDigit('0')),
            showCancel ? Align(alignment: Alignment.topLeft, child: _buildCancelButton()) : Container(),
            Align(alignment: Alignment.topRight, child: _buildDeleteButton())
          ],
        ),

        /*
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            showCancel ? _buildCancelButton() : Container(),
            _buildKeyboardDigit('0'),
            _buildDeleteButton()
          ],
        ),
        */
      ],
    );
  }

  Widget _buildKeyboardDigit(String text) {
    return Container(
      margin: keyboardUIConfig.keyboardRowMargin,
      width: keyboardUIConfig.digitSize,
      height: keyboardUIConfig.digitSize,
      child: ClipOval(
        child: Material(
          color: keyboardUIConfig.digitFillColor,
          child: InkWell(
            highlightColor: keyboardUIConfig.primaryColor,
            splashColor: keyboardUIConfig.primaryColor.withOpacity(0.4),
            onTap: () {
              onKeyboardTap(text);
            },
            child: Center(
              child: Text(
                text,
                style: keyboardUIConfig.digitTextStyle,
              ),
            ),
          ),
        ),
      ),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        /*
        border: Border.all(
            color: keyboardUIConfig.primaryColor,
            width: keyboardUIConfig.digitBorderWidth),
        */
      ),
    );
  }

  Widget _buildCancelButton() {
    return Container(
      margin: keyboardUIConfig.deleteButtonMargin,
      height: keyboardUIConfig.digitSize,
      width: keyboardUIConfig.digitSize,
      child: ClipOval(
        child: Material(
          color: keyboardUIConfig.digitFillColor,
          child: InkWell(
            highlightColor: keyboardUIConfig.primaryColor,
            splashColor: keyboardUIConfig.primaryColor.withOpacity(0.4),
            onTap: onCancelTap,
            child: Center(
              child: Text(
                cancelLocalizedText,
                style: keyboardUIConfig.deleteButtonTextStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Container(
      margin: keyboardUIConfig.deleteButtonMargin,
      height: keyboardUIConfig.digitSize,
      width: keyboardUIConfig.digitSize,
      child: ClipOval(
        child: Material(
          color: keyboardUIConfig.digitFillColor,
          child: InkWell(
            highlightColor: keyboardUIConfig.primaryColor,
            splashColor: keyboardUIConfig.primaryColor.withOpacity(0.4),
            onTap: onDeleteTap,
            child: Center(
              child: Icon(
                Icons.backspace,
                color: keyboardUIConfig.deleteButtonTextStyle.color,
              ),
            ),
          ),
        )
      ),
    );
  }
}

class ShakeCurve extends Curve {
  @override
  double transform(double t) {
    //t from 0.0 to 1.0
    return sin(t * 3 * pi).abs();
  }
}