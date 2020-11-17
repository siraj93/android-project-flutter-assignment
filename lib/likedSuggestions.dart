import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hello_me/models/user.dart';
import 'package:hello_me/homePage.dart';


class SavedSuggestions extends StatefulWidget {
  final RandomWordsState homePage;
  SavedSuggestions({Key key, this.homePage}) : super(key: key);
  @override
  _SavedSuggestions createState() => _SavedSuggestions(homePage);

}

class _SavedSuggestions extends State<SavedSuggestions> {
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);
  bool authenticated;
  RandomWordsState homePage;
  Set<String> _saved;
  _SavedSuggestions(RandomWordsState homePage){
    this.homePage = homePage;
    this._saved = {};
    this.authenticated = false;
  }

  Widget _buildRow(String pair) {
    final user = Provider.of<UserRepository>(context);
    return ListTile(
      title: Text(
        pair,
        style: _biggerFont,
      ),
      trailing: Icon(Icons.delete_outline),
      onTap: (){
        setState(() {
          if (authenticated) {
            user.removePairFromSaved(pair);
          } else{
            _saved.remove(pair);
            homePage.removeStringFromSaved(pair);
          }
        });
        if (authenticated)
          user.removePairFromSaved(pair);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserRepository>(context);
    if (user.status == Status.Authenticated){
      authenticated = true;
      user.saved.forEach((element) {
        _saved.add(element);
      });
    } else {
      homePage.saved.forEach((element) {
        _saved.add(element.asPascalCase);
      });
    }
    return Consumer(
        builder: (context, UserRepository user, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: new ListView.builder(
                itemBuilder: (context, i){
                  if (i.isOdd) {
                    return Divider();
                  }

                  // The syntax "i ~/ 2" divides i by 2 and returns an
                  // integer result.
                  // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
                  // This calculates the actual number of word pairings
                  // in the ListView,minus the divider widgets.
                  final int index = i ~/ 2;
                  if (authenticated){
                    if (index >= user.saved.length){
                      return null;
                    } else {
                      return _buildRow(user.saved[index]);
                    }
                  }else {
                    if (index >= _saved.length){
                      return null;
                    }else{
                      return _buildRow(_saved.elementAt(index));
                    }
                  }
                }),
          );}


    );}

}