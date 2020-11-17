// import 'package:flutter/material.dart';
// import 'package:snapping_sheet/snapping_sheet.dart';
//
// class SnapSheet extends StatefulWidget{
//   @override
//   _SnapSheetState createState() => _SnapSheetState();
// }
//
// class _SnapSheetState extends State<SnapSheet> {
//   @override
//   Widget build(BuildContext context) {
//     return SnappingSheet(
//           sheetAbove: SnappingSheetContent(
//               child: Container(
//                 color: Colors.red,
//               ),
//               heightBehavior: SnappingSheetHeight.fit()),
//
//           grabbing: Container(
//             color: Colors.blue
//           ),
//     );
//   }
// }

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/models/user.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

//
// class ListViewSnapSheetExample extends StatefulWidget {
//   @override
//   _ListViewSnapSheetExampleState createState() => _ListViewSnapSheetExampleState();
// }
//
// class _ListViewSnapSheetExampleState extends State<ListViewSnapSheetExample> with SingleTickerProviderStateMixin{
//   var _controller = SnappingSheetController();
//   AnimationController _arrowIconAnimationController;
//   Animation<double> _arrowIconAnimation;
//
//   double _moveAmount = 0.0;
//
//   @override
//   void initState() {
//     super.initState();
//     _arrowIconAnimationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
//     _arrowIconAnimation = Tween(begin: 0.0, end: 0.5).animate(CurvedAnimation(
//         curve: Curves.elasticOut,
//         reverseCurve: Curves.elasticIn,
//         parent: _arrowIconAnimationController)
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('ListView example'),
//       ),
//       body: SnappingSheet(
//         sheetAbove: SnappingSheetContent(
//           child: Padding(
//             padding: EdgeInsets.only(bottom: 20.0),
//             child: Align(
//               alignment: Alignment(0.90, 1.0),
//               child: FloatingActionButton(
//                 onPressed: () {
//                   if(_controller.snapPositions.last != _controller.currentSnapPosition) {
//                     _controller.snapToPosition(_controller.snapPositions.last);
//                   }
//                   else {
//                     _controller.snapToPosition(_controller.snapPositions.first);
//                   }
//                 },
//                 child: RotationTransition(
//                   child: Icon(Icons.arrow_upward),
//                   turns: _arrowIconAnimation,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         onSnapEnd: () {
//           if(_controller.snapPositions.last != _controller.currentSnapPosition) {
//             _arrowIconAnimationController.reverse();
//           }
//           else {
//             _arrowIconAnimationController.forward();
//           }
//         },
//         onMove: (moveAmount) {
//           setState(() {
//             _moveAmount = moveAmount;
//           });
//         },
//         snappingSheetController: _controller,
//         snapPositions: const [
//           SnapPosition(positionPixel: 0.0, snappingCurve: Curves.elasticOut, snappingDuration: Duration(milliseconds: 750)),
//           SnapPosition(positionFactor: 0.4),
//           SnapPosition(positionFactor: 0.8),
//         ],
//         child: Column(  // if snapped, blur?
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Moved ${_moveAmount.round()} pixels',
//               style: TextStyle(fontSize: 20.0),
//             ),
//           ],
//         ),
//         grabbingHeight: MediaQuery.of(context).padding.bottom + 50,
//         grabbing: GrabSection(controller: _controller),
//         sheetBelow: SnappingSheetContent(
//             child: SheetContent()
//         ),
//       ),
//     );
//   }
// }


class MyImage extends StatefulWidget{
  final String imageUrl;
  MyImage({Key key, this.imageUrl}) : super(key: key);
  @override
  MyImageState createState() => MyImageState();
}

class MyImageState extends State<MyImage>{
  final String imageUrl;
  MyImageState({ this.imageUrl}) ;
  @override
  Widget build(BuildContext context) {
    return Image.network(imageUrl, height: 80, width: 80);
  }
}


class SheetContent extends StatefulWidget{
  @override
  SheetContentState createState() => SheetContentState();
}

class SheetContentState extends State<SheetContent>{
  final _key = GlobalKey<ScaffoldState>();
  File _imageAsFile ;
  PickedFile _image;
  String _imageUrl;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserRepository>(context);
    String email = user.email;
    return Container(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            width: 100,
            margin: EdgeInsets.only(left: 10, top: 25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5.0),
                topRight: Radius.circular(5.0),
                bottomLeft: Radius.circular(5.0),
                bottomRight: Radius.circular(5.0),
              ),
            ),
            child: (_imageUrl != null)
                ? MyImage(imageUrl: _imageUrl,)
                : CircleAvatar(
              // backgroundImage: null,
              backgroundColor: Colors.grey[350],
              child: Text('A'),
              maxRadius: 40,
            ),
          ),
          Container(
            alignment: Alignment.topRight,
              margin: EdgeInsets.only(left: 20, top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: SizedBox(
                      height: 50,
                      width: 250,
                      child: AutoSizeText("$email",
                        style: TextStyle(fontSize: 20),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.green[300],
                    child: MaterialButton(
                      height: 50,
                      onPressed: () async {
                        pickImage(ImageSource.gallery);
                        user.uploadFile(_imageAsFile);
                      },
                      child: Text(
                        "Change Avatar",
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  pickImage(ImageSource imageSource) async {
    final user = Provider.of<UserRepository>(context);
    final imagePicker = ImagePicker();
    PickedFile image = await imagePicker.getImage(source: imageSource);
    if (image != null) {
      _imageAsFile = File(image.path);
      if (!await user.uploadFile(_imageAsFile))
        print("upload failed");
      print("Uploaded image");
      setState(() {

        _imageUrl = user.imageURL;
      });

    }else{
      _key.currentState.showSnackBar(SnackBar(
        content: Text(
            "There was an error logging into the app"
        ),
      ));
    }
  }

}


class GrabSection extends StatelessWidget {
  final controller;
  final Animation<double> arrowIconAnimation;
  GrabSection({Key key,
    @required this.controller, this.arrowIconAnimation}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserRepository>(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[400],
        boxShadow: [BoxShadow(
          blurRadius: 20.0,
          color: Colors.black.withOpacity(0.3),
        )],
        // backgroundBlendMode: ,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: SizedBox(
              width: 330,
              child: AutoSizeText("Welcome back, ${user.email}",
                style: TextStyle(fontSize: 30),
                maxLines: 1,
                textAlign: TextAlign.start,
              ),
            ),
            margin: EdgeInsets.only(left: 10),
          ),
          Container(
              margin: EdgeInsets.only(right: 20),
              child: RotationTransition(
                child: IconButton(icon: Icon(Icons.arrow_upward), onPressed: () {
                  if(controller.snapPositions.last != controller.currentSnapPosition) {
                    controller.snapToPosition(controller.snapPositions.last);
                  }
                  else {
                    controller.snapToPosition(controller.snapPositions.first);
                  }
                },),
                turns: arrowIconAnimation, )

          ),
        ],
      ),
    );
  }
}