import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'dart:io';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class UserRepository with ChangeNotifier {
  FirebaseAuth _auth;
  User _user;
  Status _status = Status.Uninitialized;
  List<String> _saved = [];
  String _documentID;
  String _email;
  String _imageURL;

  UserRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Status get status => _status;
  User get user => _user;
  String get email => _email;
  get saved => _saved;

  get imageURL => _imageURL;

  String _imageSTR;

  String get imageSTR => _imageSTR;

  set imageSTR(String imageSTR) {_imageSTR = imageSTR;}

  set imageURL(String imageURL) {
    _imageURL = imageURL;
  }

  set saved(List<String> suggestions){
    suggestions.forEach((element) {
      if (!_saved.contains(element)) {
        _saved.add(element);
      }
    });
  }


  String get documentID => _documentID;

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _email = email;
      var snapShot = await getUser();

      if (snapShot == null || !snapShot.exists) {
        _addUser();
      }
      _documentID = email;
      return true;
    } catch (e) {
      print("sign in failed: $e");
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _email = email;
      var snapShot = await getUser();

      if (snapShot == null || !snapShot.exists) {
        _addUser();
      }
      _documentID = email;
      return true;
    } catch (e) {
      print("sign up failed: $e");
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }
  Future<void> updateUserSavedSuggestion(Set<WordPair> suggestions) {
    suggestions.forEach((element) {
      if (_saved != null && !_saved.contains(element)) {
        _saved.add(element.asPascalCase);
      }
    });

    return users.doc(_documentID)
        .update({'savedSuggestions': [...{..._saved}]});
  }

  Future<void> removePairFromSaved(String pair){
    _saved.remove(pair);
    return users.doc(_documentID)
        .update({'savedSuggestions': [...{..._saved}]});
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    if (_email != ""){
      _email = "";
    }
    _saved = [];
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(User firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }

  Future<DocumentSnapshot> getUser() {
    return users
        .doc(_email)
        .get();
  }

  Future uploadFile(File _image) async {
    Reference storageReference = FirebaseStorage.instance
        .ref('images')
        .child('${Path.basename(_image.path)}');
    UploadTask  uploadTask = storageReference.putFile(_image);
    TaskSnapshot snapshot = await uploadTask.snapshot;
    print('File Uploaded');
    snapshot.ref.getDownloadURL().then((fileURL) {
        _imageSTR = fileURL;
        users.doc(_documentID)
            .update({'image': _imageSTR});
    })
        .then((value) => _getImageURL(_imageSTR))
        .then((url) {
          _imageURL = url;
          users.doc(_documentID)
              .update({'imageUrl': _imageURL});
        });

  }

  Future<String> _getImageURL(String name){
    return FirebaseStorage.instance.ref('images').child(name).getDownloadURL();
  }



  Future<void> _addUser() {
    if (_saved == null){
      _saved = [];
    }
    return users
        .doc(_email)
        .set({
      'email': _email,
      'savedSuggestions': _saved,
    })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}
