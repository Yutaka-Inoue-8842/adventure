import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';


class UserState extends ChangeNotifier{
  User user;
  void setUser(User currentUser){
    user = currentUser;
    notifyListeners();
  }
}




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Myapp());
}


class Myapp extends StatelessWidget {
  final UserState userState = UserState();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserState>(
      create: (context) => UserState(),
      child: MaterialApp(
        title: 'adventure',
        home: LoginCheck(),
      ),
    );
  }
}

// ログインチェック

class LoginCheck extends StatefulWidget{
  LoginCheck({Key key}) : super(key: key);

  @override
  _LoginCheckState createState() => _LoginCheckState();

}

class _LoginCheckState extends State<LoginCheck>{
  //ログイン状態のチェック(非同期で行う)
  void checkUser() async{
    final currentUser = await FirebaseAuth.instance.currentUser;
    final userState = Provider.of<UserState>(context,listen: false);
    if(currentUser == null){
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return Login();
          }),
        );
    }else{
      userState.setUser(currentUser);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return Destination();
        }),
      );
    }
  }

  @override
  void initState(){
    super.initState();
    checkUser();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Text("Loading..."),
        ),
      ),
    );
  }
}


//ログインページ



class Login extends StatelessWidget {
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
                final FirebaseAuth auth = FirebaseAuth.instance;
                final result = await auth.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                userState.setUser(result.user);
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return Destination();
                  }),
                );
              } catch (e) { 
                  setState(() {
                    error = e.toString();
                  });
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
                final FirebaseAuth auth = FirebaseAuth.instance;
                final result = await auth.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                userState.setUser(result.user);
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return Destination();
                  })
                );
              } catch (e) { 
                  setState(() {
                  error = e.toString();
                  });
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




class Destination extends StatelessWidget {
   @override
  Widget build(BuildContext context){
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user;
    
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
        title: Text(
          'Destination',
          style: TextStyle(
            color: Colors.black
          ),
        ),
        backgroundColor: Colors.white,
        ),
        body: Grid(),
      ),
    );
  }
}

class Grid extends StatelessWidget {

  @override
  Widget build(BuildContext context){
    return Container(
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        shrinkWrap: true,
        padding: const EdgeInsets.all(8.0),
        children:[
          Container(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: 0.8,
                  child: Image.asset('images/aurora.jpg', fit: BoxFit.cover,)
                ),
                Center(
                  child: Text(
                    'Aurora',
                    style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            )
          ),
          Container(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: 0.8,
                  child: Image.asset('images/volcano.jpeg', fit: BoxFit.cover,)
                ),
                Center(
                  child: Text(
                    'Volcano',
                    style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            )
          ),
          Container(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: 0.8,
                  child: Image.asset('images/desert.jpeg', fit: BoxFit.cover,)
                ),
                Center(
                  child: Text(
                    'Desert',
                    style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            )
          ),
          Container(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: 0.8,
                  child: Image.asset('images/jungle.jpeg', fit: BoxFit.cover,)
                ),
                Center(
                  child: Text(
                    'Jungle',
                    style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            )
          ),
          Container(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: 0.8,
                  child: Image.asset('images/snow mountain.jpeg', fit: BoxFit.cover,)
                ),
                Center(
                  child: Text(
                    'Snow\nMountain',
                    style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            )
          ),
          Container(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: 0.8,
                  child: Image.asset('images/permafrost.jpg', fit: BoxFit.cover,)
                ),
                Center(
                  child: Text(
                    'Permafrost',
                    style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            )
          ),
          Container(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: 0.8,
                  child: Image.asset('images/deep sea.jpeg', fit: BoxFit.cover,)
                ),
                Center(
                  child: Text(
                    'Deep sea',
                    style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            )
          ),
          Container(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: 0.8,
                  child: Image.asset('images/earth.webp', fit: BoxFit.cover,)
                ),
                Center(
                  child: Text(
                    'Other',
                    style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            )
          ),
        ]
      ),
    );
  }
}
