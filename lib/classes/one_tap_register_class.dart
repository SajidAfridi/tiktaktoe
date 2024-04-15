import 'package:flutter/material.dart' show
StatelessWidget, Widget, BuildContext, RawGestureDetector,
GestureRecognizerFactory, GestureRecognizerFactoryWithHandlers
;
import 'package:flutter/gestures.dart' show
OneSequenceGestureRecognizer, PointerDownEvent, GestureDisposition,
PointerEvent
;

class OnlyOnePointerRecognizer extends OneSequenceGestureRecognizer {
  int _p = 0;

  @override
  void addPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer);

    if (_p == 0) {
      resolve(GestureDisposition.rejected);
      _p = event.pointer;
    } else {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  String get debugDescription => 'only one pointer recognizer';

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  void handleEvent(PointerEvent event) {
    if (!event.down && event.pointer == _p) {
      _p = 0;
    }
  }
}

class OnlyOnePointerRecognizerWidget extends StatelessWidget {
  final Widget? child;

  const OnlyOnePointerRecognizerWidget({super.key,  this.child });

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          OnlyOnePointerRecognizer: GestureRecognizerFactoryWithHandlers<OnlyOnePointerRecognizer>(
                  () => OnlyOnePointerRecognizer(),
                  (OnlyOnePointerRecognizer instance) {}
          )
        },
        child: child
    );
  }
}