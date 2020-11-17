1) Widgets usually expose controllers to allow the developer granular control
over certain features. You’ve already used one when you implemented
TextFields in the previous assignment (Remember?).
Read this thread and then go to snapping_sheet ’s documentation.
Answer : What class is used to implement the controller pattern in this library?
What features does it allow the developer to control?

*)It is called "snappingSheetController", and it features: Controling the sheet and getting current snap position.


2) The library allows the bottom sheet to snap into position with various different
animations. What parameter controls this behavior?

*)
A) /// The controller for the snapping animation
  AnimationController _snappingAnimationController;
B) /// The snapping animation
  Animation<double> _snappingAnimation;





3) (This question does not directly relate to the previous ones) . Read the
documentation of InkWell and GestureDetector . Name one advantage of
InkWell over the latter and one advantage of GestureDetector over the first.

*)GestureDetector provides more controls like dragging etc. on the other hand it doesn't include ripple effect tap, which InkWell does. 