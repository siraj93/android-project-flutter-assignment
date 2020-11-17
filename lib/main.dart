import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hello_me/models/user.dart';
import 'package:hello_me/homePage.dart';
import 'package:hello_me/likedSuggestions.dart';
import 'package:hello_me/snapSheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
class MyApp extends StatelessWidget {
  //TODO: Remove consumer here and add routes list
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (_) => UserRepository.instance(),
      child:  MaterialApp(
        title: 'Startup Name Generator',
        theme: ThemeData(
          primaryColor: Colors.red,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => RandomWords(),
          '/login': (context) => LoginPage(),
          '/marked': (context) => SavedSuggestions(),
        },
      ),
    );
  }
}

// // ignore: must_be_immutable
// class HomePage extends StatelessWidget {
//   bool authAttempted = false;
//   @override
//   Widget build(BuildContext context) {
//     return Consumer(
//       builder: (context, UserRepository user, _) {
//         if (!(user.status == Status.Authenticated) && !authAttempted){
//           return RandomWords();
//         }
//         if (user.status == Status.Authenticating){
//           authAttempted = true;
//           return LoginPage();
//         }
//         switch (user.status){
//           case Status.Uninitialized:
//           case Status.Authenticated:
//             return RandomWords();
//           case Status.Unauthenticated:
//             authAttempted = false;
//             return LoginPage();
//           case Status.Authenticating:
//             return LoginPage();
//         }
//         return RandomWords();
//       },
//     );
//   }
// }
//



// class RandomWords extends StatefulWidget {
//   @override
//   _RandomWordsState createState() => _RandomWordsState();
// }
//
// class _RandomWordsState extends State<RandomWords> {
//   final List<WordPair> _suggestions = <WordPair>[];
//   final _saved = Set<WordPair>();
//   final TextStyle _biggerFont = const TextStyle(fontSize: 18);
//   Widget _buildSuggestions() {
//     return ListView.builder(
//         padding: const EdgeInsets.all(16),
//         // The itemBuilder callback is called once per suggested
//         // word pairing, and places each suggestion into a ListTile
//         // row. For even rows, the function adds a ListTile row for
//         // the word pairing. For odd rows, the function adds a
//         // Divider widget to visually separate the entries. Note that
//         // the divider may be difficult to see on smaller devices.
//         itemBuilder: (BuildContext _context, int i) {
//           // Add a one-pixel-high divider widget before each row
//           // in the ListView.
//           if (i.isOdd) {
//             return Divider();
//           }
//
//           // The syntax "i ~/ 2" divides i by 2 and returns an
//           // integer result.
//           // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
//           // This calculates the actual number of word pairings
//           // in the ListView,minus the divider widgets.
//           final int index = i ~/ 2;
//           // If you've reached the end of the available word
//           // pairings...
//           if (index >= _suggestions.length) {
//             //   // ...then generate 10 more and add them to the
//             //   // suggestions list.
//             _suggestions.addAll(generateWordPairs().take(10));
//           }
//           return _buildRow(_suggestions[index]);
//         }
//     );
//   }
//
//   Widget _buildRow(WordPair pair) {
//     final user = Provider.of<UserRepository>(context);
//     final inCloud = user._saved.contains(pair.asPascalCase);
//     final alreadySaved = _saved.contains(pair);
//
//     return ListTile(
//       title: Text(
//         pair.asPascalCase,
//         style: _biggerFont,
//       ),
//       trailing: user.status == Status.Authenticated
//           ? Icon(
//         inCloud ? Icons.favorite : Icons.favorite_border,
//         color: inCloud ? Colors.red : null,
//       )
//           : Icon(
//         alreadySaved ? Icons.favorite : Icons.favorite_border,
//         color: alreadySaved ? Colors.red : null,
//       ),
//       onTap: (){
//         setState(() {
//           if (user.status == Status.Authenticated){
//             if(inCloud){
//               user.removePairFromSaved(pair.asPascalCase);
//             }else{
//               user._updateUserSavedSuggestion({pair});
//             }
//           }else{
//             if (alreadySaved) {
//               _saved.remove(pair);
//             }else{
//               _saved.add(pair);
//             }
//           }
//         });
//         if (user.status == Status.Authenticated)
//           user._updateUserSavedSuggestion(_saved);
//       },
//     );
//   }
//
//   Widget buildTile(WordPair pair){
//     return ListTile(
//       title: Text(pair.asPascalCase),
//       trailing: Icon(Icons.delete_outline),
//       onTap: (){
//         setState(() {
//           _saved.remove(pair);
//         });
//       },
//     );
//   }
//   Widget buildTileAsync(String pair){
//     final user = Provider.of<UserRepository>(context);
//     return ListTile(
//       title: Text(pair),
//       trailing: Icon(Icons.delete_outline),
//       onTap: (){
//         setState(() {
//           user._saved.remove(pair);
//         });
//         user.removePairFromSaved(pair);
//       },
//     );
//   }
//
//
//
//   Widget _pushSaved() {
//     final user = Provider.of<UserRepository>(context);
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('Saved Suggestions'),
//         ),
//         body: new ListView.separated(
//             itemCount: user.status == Status.Authenticated
//                 ? user._saved.length
//                 : (_saved != null) ? _saved.length : 0,
//             separatorBuilder: (context, index) =>
//                 Divider(height: 1.0, color: Colors.grey),
//             itemBuilder: (context, index){
//               return user.status == Status.Authenticated
//                   ? buildTileAsync(user._saved[index])
//                   : buildTile(_saved.elementAt(index));
//
//             }),);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = Provider.of<UserRepository>(context);
//     Scaffold scaffold = Scaffold(appBar: AppBar(
//       title: Text('Startup Name Generator'),
//       actions: [
//         IconButton(icon: Icon(Icons.list), onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => _pushSaved()
//             ),
//           );
//         },) ,
//         if (user.status == Status.Authenticated) IconButton(
//           icon: Icon(Icons.exit_to_app),
//           onPressed: () => Provider.of<UserRepository>(context).signOut(),)
//         else IconButton(
//             icon: Icon(Icons.login),
//             onPressed: () => _loginScreen()),
//       ],
//     ),
//         body: _buildSuggestions()
//     );
//
//     if (user.status == Status.Authenticated){
//       return FutureBuilder<DocumentSnapshot>(
//         future: user._getUser(),
//         builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return Text("Something went wrong");
//           }
//           if (snapshot.connectionState == ConnectionState.done
//               && snapshot.hasData) {
//             Map<String, dynamic> data = snapshot.data.data();
//
//             user._saved = data.containsKey('savedSuggestions')
//                 ? List.from(data['savedSuggestions'])
//                 : [];
//             print("User _saved UPDATED");
//             if (_saved.isNotEmpty){
//               user._updateUserSavedSuggestion(_saved);
//               _saved.clear();
//             }
//             return scaffold;
//           }
//           return scaffold;
//         },
//       );
//     }
//     return scaffold;
//   }
//
//   void _loginScreen() {
//     Navigator.of(context).push(
//         MaterialPageRoute<void>(builder: (BuildContext context){
//           return LoginPage();
//         })
//     );
//   }
// }

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  TextEditingController _email;
  TextEditingController _password;
  TextEditingController _passwordConfirm;
  bool _passwordsEqual = true;
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: "");
    _password = TextEditingController(text: "");
    _passwordConfirm = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, UserRepository user, _) {
          return Scaffold(
            key: _key,
            appBar: AppBar(
              title: Text("Login"),
            ),
            body: Form(
              key: _formKey,
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    const SizedBox(height: 35,
                      child: Text(
                          "Welcome to Startup Names Generator,"
                              " please log in below"
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _email,
                        style: style,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                                Icons.email),
                            labelText: "Email",
                            border: OutlineInputBorder()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _password,
                        style: style,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            labelText: "Password",
                            border: OutlineInputBorder()),
                        obscureText: true,
                      ),
                    ),
                    user.status == Status.Authenticating
                        ? Center(child: CircularProgressIndicator())
                        : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.red,
                        child: MaterialButton(
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              if (!await user.signIn(
                                  _email.text, _password.text)) {
                                _key.currentState.showSnackBar(SnackBar(
                                  content: Text(
                                      "There was an error logging into the app"
                                  ),
                                ));
                                return;
                              } else {
                                Navigator.popUntil(
                                    context, (route) => route.isFirst);
                                Navigator.pushReplacementNamed(context, '/');
                              }
                            }
                          },
                          child: Text(
                            "Login",
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.lightGreen,
                        child: MaterialButton(
                          onPressed: () async {
                            _passwordConfirm.addListener(() async{ passwordConfirmText();});
                            modalbottomSheet();
                          },
                          child: Text(
                            "New user? Click to sign up",
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
  void modalbottomSheet(){
    final user = Provider.of<UserRepository>(context);
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 250,
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(16.0),
                    child: Text(
                      "Please confirm your password below:",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(),
                  passwordConfirmText(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.green[700],
                      child: MaterialButton(
                        onPressed: () async {
                          setState(() {
                            _passwordsEqual =
                            (_password.text == _passwordConfirm.text);
                            print("_passwordsEqual: $_passwordsEqual");
                          });
                          if (_passwordsEqual){
                            if (_formKey.currentState.validate()) {
                              if(await user.signUp(
                                  _email.text, _password.text)) {
                                Navigator.popUntil(context, (route) => route.isFirst);
                                Navigator.pushReplacementNamed(context, '/');

                              }
                            }
                          }
                        },
                        child: Text(
                          "Confirm",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),);
        });
  }

  Widget passwordConfirmText(){
    return new Container(
      color: Colors.white.withOpacity(0.5),
      margin: EdgeInsets.all(16.0),
      child: TextFormField(
        controller: _passwordConfirm,
        style: style,
        decoration: InputDecoration(
            errorText:
            _passwordsEqual ? ""
                : 'Passwords must match',
            prefixIcon: Icon(Icons.lock),
            labelText: "Password",
            border: OutlineInputBorder()),
        obscureText: true,

      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}

