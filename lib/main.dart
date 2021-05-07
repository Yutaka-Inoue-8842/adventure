import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import './top_page.dart'; 

class UserState extends ChangeNotifier {
  User user;

  void setUser(User newUser) {
    user = newUser;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // new
  //最初に表示するwidget
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final UserState userState = UserState();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserState>(
      create: (context) => UserState(),
      child: MaterialApp(
        title: 'adventure',
        home: LoginPage(),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
   @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Haeder(),
            Body(),
          ]
        ),
      ),
    );
  }
}


class Haeder extends StatelessWidget {
   @override
  Widget build(BuildContext context){   
    return Container(
      height: 300,
      padding: EdgeInsets.only(top: 130),
      child: Text(
        'Adventure',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 50,
        ),
      ),
    );
  }
}


class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
    String email = '';
    String password = '';
    String error = '';
    @override
  Widget build(BuildContext context){
    final UserState userState = Provider.of<UserState>(context);
    return Container(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Column(
        children: <Widget>[
          TextFormField(
            onChanged: (String value) {
              setState(() {
              email = value;
              });
            },
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelText: 'Email',
              border: OutlineInputBorder(
              ),
            ),
          ),
          SizedBox(height: 50),
          TextFormField(
            onChanged: (String value) {
              setState(() {
              password = value;
              });
            },
            obscureText: true,
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelText: 'Password',
              border: OutlineInputBorder(
              ),
            ),
          ),
                        Container(
                padding: EdgeInsets.all(8),
                // メッセージ表示
                child: Text(error),
              ),
          SizedBox(height: 50),
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.only(top: 15, right: 40, bottom: 15, left: 40),
            ),
            onPressed: () async {
              try {
                // メール/パスワードでログイン
                final FirebaseAuth auth = FirebaseAuth.instance;
                final result = await auth.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                // ユーザー情報を更新
                userState.setUser(result.user);
                // ログインに成功した場合
                // チャット画面に遷移＋ログイン画面を破棄
                await Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) {
                    return TopPage();
                  }),
                );
              } catch (e) { 
                                     // ユーザー登録に失敗した場合
                      setState(() {
                        error = "ログインに失敗しました：${e.toString()}";
                      });
                  // ログインに失敗した場合
                }
            },
            child: Text(
              'Sign in',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white
              ),
            ),
          ),
          SizedBox(height: 25),
          TextButton( 
            onPressed: () async {
              try {
                // メール/パスワードでログイン
                final FirebaseAuth auth = FirebaseAuth.instance;
                final result = await auth.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                // ユーザー情報を更新
                userState.setUser(result.user);
                // ログインに成功した場合
                // チャット画面に遷移＋ログイン画面を破棄
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return TopPage();
                  })
                );
              } catch (e) { 
                                      setState(() {
                        error = "登録に失敗しました：${e.toString()}";
                      });
                  // ログインに失敗した場合
                }
            },
            child: Text(
              'Sign up',
                style: TextStyle(
                color: Colors.black
              ),
            ),
          ),
        ],
      ),
    );
  }
}