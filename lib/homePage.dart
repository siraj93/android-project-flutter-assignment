import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:hello_me/likedSuggestions.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hello_me/models/user.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:hello_me/snapSheet.dart';
import 'dart:ui';

enum snappingStatus { OPENED, CLOSED }

class RandomWords extends StatefulWidget {
  final Set<String> toRemove;
  RandomWords({Key key, this.toRemove}) : super(key: key);
  @override
  RandomWordsState createState() => RandomWordsState(this.toRemove);
}

class RandomWordsState extends State<RandomWords> with SingleTickerProviderStateMixin{
  final List<WordPair> _suggestions = <WordPair>[];
  final Set<WordPair> _saved = Set<WordPair>();

  void addToSaved(WordPair pair){
    _saved.contains(pair) ? null : _saved.add(pair);
  }

  bool removeFromSaved(WordPair pair){
    return _saved.remove(pair);
  }

  bool removeStringFromSaved(String pair){
    WordPair wordPair;
    _saved.forEach((element) {
      if (element.asPascalCase == pair)
        wordPair = element;
    }
    );
    return _saved.remove(wordPair);
  }

  final TextStyle _biggerFont = const TextStyle(fontSize: 18);
  RandomWordsState(Set<String> toRemove){
    _saved.removeWhere((element) => toRemove.contains(element.asPascalCase));
  }

  get saved => _saved;

  //Snipping sheet's params
  var _controller = SnappingSheetController();
  AnimationController _arrowIconAnimationController;
  Animation<double> _arrowIconAnimation;

  @override
  void initState() {
    super.initState();
    _arrowIconAnimationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _arrowIconAnimation = Tween(begin: 0.0, end: 0.5).animate(CurvedAnimation(
        curve: Curves.elasticOut,
        reverseCurve: Curves.elasticIn,
        parent: _arrowIconAnimationController)
    );
  }

  Widget snapSheetWithBlur(){
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        snapSheet(),
        Positioned.fill(
          child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 2.0,
                sigmaY: 2.0,
              ),
              child: Scaffold(
                backgroundColor: Colors.black12,
                body: Container(),
              )
          ),
        ),
      ],
    );
  }

  Widget snapSheet(){
    var status = snappingStatus.CLOSED;
    return SnappingSheet(
      onSnapEnd: () {
        if(_controller.snapPositions.last != _controller.currentSnapPosition) {
          _arrowIconAnimationController.reverse();
          status = snappingStatus.CLOSED;
        }
        else {
          _arrowIconAnimationController.forward();
          status = snappingStatus.OPENED;
        }
      },
      onMove: (moveAmount) {
        setState(() {
          status = snappingStatus.OPENED;
        });
      },
      snappingSheetController: _controller,
      snapPositions: const [
        SnapPosition(positionPixel: 0.0, snappingCurve: Curves.elasticOut, snappingDuration: Duration(milliseconds: 750)),
        SnapPosition(positionFactor: 0.2),
      ],
      // child: _buildSuggestions(),
      child: Stack(//Consumer of snapping's controller
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            child: _buildSuggestions(),
          ),
          if(status == snappingStatus.OPENED )
            Positioned.fill(
              child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 4.0,
                    sigmaY: 4.0,
                  ),
                  child: Scaffold(
                    backgroundColor: Colors.cyan.withOpacity(0),
                    body: Container(),
                  )
              ),
            ),
        ],
      ),
      grabbingHeight: MediaQuery.of(context).padding.bottom + 50,
      grabbing: GrabSection(controller: _controller,
        arrowIconAnimation: _arrowIconAnimation,),
      sheetBelow: SnappingSheetContent(
          child: new SheetContent()
      ),
    );
  }


  Widget _buildSuggestions() {
    return new ListView.builder(
      padding: const EdgeInsets.all(16),
      // The itemBuilder callback is called once per suggested
      // word pairing, and places each suggestion into a ListTile
      // row. For even rows, the function adds a ListTile row for
      // the word pairing. For odd rows, the function adds a
      // Divider widget to visually separate the entries. Note that
      // the divider may be difficult to see on smaller devices.
      itemBuilder: (BuildContext _context, int i) {
        // Add a one-pixel-high divider widget before each row
        // in the ListView.
        if (i.isOdd) {
          return Divider();
        }

        // The syntax "i ~/ 2" divides i by 2 and returns an
        // integer result.
        // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
        // This calculates the actual number of word pairings
        // in the ListView,minus the divider widgets.
        final int index = i ~/ 2;
        // If you've reached the end of the available word
        // pairings...
        if (index >= _suggestions.length) {
          //   // ...then generate 10 more and add them to the
          //   // suggestions list.
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    final user = Provider.of<UserRepository>(context);
    final inCloud = user.saved.contains(pair.asPascalCase);
    final alreadySaved = _saved.contains(pair);

    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: user.status == Status.Authenticated
          ? Icon(
        inCloud ? Icons.favorite : Icons.favorite_border,
        color: inCloud ? Colors.red : null,
      )
          : Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: (){
        setState(() {
          if (user.status == Status.Authenticated){
            if(inCloud){
              user.removePairFromSaved(pair.asPascalCase);
            }else{
              user.updateUserSavedSuggestion({pair});
            }
          }else{
            if (alreadySaved) {
              _saved.remove(pair);
            }else{
              _saved.add(pair);
            }
          }
        });
        if (user.status == Status.Authenticated)
          user.updateUserSavedSuggestion(_saved);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserRepository>(context);
    Scaffold scaffold = Scaffold(appBar: AppBar(
      title: Text('Startup Name Generator'),
      actions: [
        IconButton(icon: Icon(Icons.list), onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) =>
              SavedSuggestions(homePage: this,),));
        },),
        if (user.status == Status.Authenticated) IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () => Provider.of<UserRepository>(context).signOut(),)
        else IconButton(
          icon: Icon(Icons.login),
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
        )
      ],
    ),
      body: (user.status == Status.Authenticated)
          ? snapSheet() : _buildSuggestions(),
    );

    if (user.status == Status.Authenticated){
      return FutureBuilder<DocumentSnapshot>(
        future: user.getUser(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.done
              && snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data.data();

            user.saved = data.containsKey('savedSuggestions')
                ? List.from(data['savedSuggestions'])
                : [];
            user.imageSTR = data.containsKey('image')
                ? data['image']
                : "";
            if (user.imageSTR != null){
              user.imageURL = data['imageUrl'];
            }
            print("User _saved UPDATED");
            if (_saved.isNotEmpty){
              user.updateUserSavedSuggestion(_saved);
              _saved.clear();
            }
            return scaffold;
          }
          return scaffold;
        },
      );
    }
    return scaffold;
  }

}
