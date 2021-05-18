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

// ↓ログインチェック↓

class LoginCheck extends StatefulWidget{
  LoginCheck({Key key}) : super(key: key);
  @override
  _LoginCheckState createState() => _LoginCheckState();
}

class _LoginCheckState extends State<LoginCheck>{
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
        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        if(snapshot.data() == null ){
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return Destination();
            }),
          );
        }else{
          userState.setUser(currentUser);
          DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return Top(snapshot.data()['roomname'], snapshot.data()['room_id']);
            }),
          );
        }
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

//↑ログインチェック↑

//↓ログインページ↓

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
    final User user = userState.user;
    return Container(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Column(
        children:[
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
                   DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return Top(snapshot.data()['roomname'], snapshot.data()['room_id']);
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
                    return NameSet();
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

//↑ログインページ↑

//↓名前設定ページ↓

class NameSet extends StatefulWidget {
  @override
  _NameSetState createState() => _NameSetState();
}
class _NameSetState extends State<NameSet> {
  String displayName = '';
  String error = '';
  @override
  Widget build(BuildContext context){
    final UserState userState = Provider.of<UserState>(context);
    return Scaffold(
      body: SafeArea(
        child:Container(
          padding: EdgeInsets.only(left: 30, right: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "What's your name?",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 50),
              TextFormField(
                onChanged: (String value) {
                  setState(() {
                    displayName = value;
                  });
                },
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
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
                    await auth.currentUser.updateProfile(displayName: displayName);
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
                  'Set',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white
                  ),
                ),
              ),
            ]
          )
        ),
      ),
    );
  }
}

//↑名前設定ページ↑

//↓行き先決定ページ↓

class Destination extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user;
    return Scaffold(
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
    );
  }
}

class Grid extends StatefulWidget {
  @override
  GridState createState() => GridState();
}
class GridState extends State<Grid> {
  var _hasPaddingAurora = false;
  var _hasPaddingVolcano = false;
  var _hasPaddingDesert = false;
  var _hasPaddingJungle = false;
  var _hasPaddingSnowMountain = false;
  var _hasPaddingPermafrost = false;
  var _hasPaddingDeepsea = false;
  var _hasPaddingOther = false;
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
          AnimatedPadding(
            duration: const Duration(milliseconds: 80),
            padding: EdgeInsets.all(_hasPaddingAurora ? 10 : 0),
            child: GestureDetector(
              onTapDown: (TapDownDetails downDetails) {
                setState(() {
                  _hasPaddingAurora = true;
                });
              },
              onTap: ()async{
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return Room('aurora');
                  }),
                );
              },
              onTapCancel: () {
                setState(() {
                  _hasPaddingAurora = false;
                });
              },
              child: Container(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: 0.8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset('images/aurora.jpg', fit: BoxFit.cover,)
                      ),
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
            ),
          ),
          AnimatedPadding(
            duration: const Duration(milliseconds: 80),
            padding: EdgeInsets.all(_hasPaddingVolcano ? 10 : 0),
            child: GestureDetector(
              onTapDown: (TapDownDetails downDetails) {
                setState(() {
                  _hasPaddingVolcano = true;
                });
              },
              onTap: ()async{
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return Room('volcano');
                  }),
                );
              },
              onTapCancel: () {
                setState(() {
                  _hasPaddingVolcano = false;
                });
              },
              child: Container(
                child: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: 0.8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('images/volcano.jpg', fit: BoxFit.cover,)
                    ),
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
          ),
        ),
        AnimatedPadding(
          duration: const Duration(milliseconds: 80),
          padding: EdgeInsets.all(_hasPaddingDesert ? 10 : 0),
          child: GestureDetector(
            onTapDown: (TapDownDetails downDetails) {
              setState(() {
                _hasPaddingDesert = true;
              });
            },
            onTap: ()async{
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return Room('desert');
                }),
              );
            },
            onTapCancel: () {
              setState(() {
                _hasPaddingDesert = false;
              });
            },
            child: Container(
              child: Stack(
                fit: StackFit.expand,
                children:[
                  Opacity(
                    opacity: 0.8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('images/desert.jpg', fit: BoxFit.cover,)
                    ),
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
          ),
        ),
        AnimatedPadding(
          duration: const Duration(milliseconds: 80),
          padding: EdgeInsets.all(_hasPaddingJungle ? 10 : 0),
          child: GestureDetector(
            onTapDown: (TapDownDetails downDetails) {
              setState(() {
                _hasPaddingJungle = true;
              });
            },
            onTap: ()async{
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return Room('jungle');
                }),
              );
            },
            onTapCancel: () {
              setState(() {
                _hasPaddingJungle = false;
              });
            },
            child: Container(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Opacity(
                    opacity: 0.8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('images/jungle.jpg', fit: BoxFit.cover,)
                    ),
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
          ),
        ),
        AnimatedPadding(
          duration: const Duration(milliseconds: 80),
          padding: EdgeInsets.all(_hasPaddingSnowMountain ? 10 : 0),
          child: GestureDetector(
            onTapDown: (TapDownDetails downDetails) {
              setState(() {
                _hasPaddingSnowMountain = true;
              });
            },
            onTap: ()async{
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return Room('snow mountain');
                }),
              );
            },
            onTapCancel: () {
              setState(() {
                _hasPaddingSnowMountain = false;
              });
            },
            child: Container(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Opacity(
                    opacity: 0.8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('images/snow mountain.jpg', fit: BoxFit.cover,)
                    ),
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
          ),
        ),
        AnimatedPadding(
          duration: const Duration(milliseconds: 80),
          padding: EdgeInsets.all(_hasPaddingPermafrost ? 10 : 0),
          child: GestureDetector(
            onTapDown: (TapDownDetails downDetails) {
              setState(() {
                _hasPaddingPermafrost = true;
              });
            },
            onTap: ()async{
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return Room('permafrost');
                }),
              );
            },
            onTapCancel: () {
              setState(() {
                _hasPaddingPermafrost = false;
              });
            },
            child: Container(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Opacity(
                    opacity: 0.8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('images/permafrost.jpg', fit: BoxFit.cover,)
                    ),
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
          ),
        ),
        AnimatedPadding(
      duration: const Duration(milliseconds: 80),
      padding: EdgeInsets.all(_hasPaddingDeepsea ? 10 : 0),
        child: GestureDetector(
          onTapDown: (TapDownDetails downDetails) {
            setState(() {
              _hasPaddingDeepsea = true;
            });
          },
          onTap: ()async{
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return Room('deep sea');
                }),
              );
            },
            onTapCancel: () {
              setState(() {
                _hasPaddingDeepsea = false;
              });
            },
            child: Container(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Opacity(
                    opacity: 0.8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('images/deep sea.jpg', fit: BoxFit.cover,)
                    ),
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
          ),
        ),
        AnimatedPadding(
          duration: const Duration(milliseconds: 80),
          padding: EdgeInsets.all(_hasPaddingOther ? 10 : 0),
          child: GestureDetector(
            onTapDown: (TapDownDetails downDetails) {
              setState(() {
                _hasPaddingOther = true;
              });
            },
            onTap: ()async{
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return Room('Other');
                }),
              );
            },
            onTapCancel: () {
              setState(() {
                _hasPaddingOther = false;
              });
            },
            child: Container(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: 0.8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('images/earth.jpg', fit: BoxFit.cover,)
                    ),
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
          ),
        ),
      ]
    ),
  );
}
}

//↑行き先決定ページ↑

//↓部屋一覧ページ↓

class Room extends StatelessWidget {
  Room(this.roomname);
  String roomname;
  @override
  Widget build(BuildContext context){
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black
            ),
            onPressed: () async {
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return Destination();
                  }),
                );
              },
            ),
            title: Text(
              'Room',
              style: TextStyle(
                color: Colors.black
              ),
            ),       
            backgroundColor: Colors.white,
          ),
          body: RoomList(roomname),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.black,
            child: Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return AddRoom(roomname);
              }),
            );
          },
        ),
      );
    }
  }

class RoomList extends StatelessWidget {
  RoomList(this.roomname);
  String roomname;
  @override
  Widget build(BuildContext context){
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user;
    CollectionReference aurora = FirebaseFirestore.instance.collection(roomname);
    return StreamBuilder<QuerySnapshot>(
      stream: aurora.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading');
        }
          return  ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              return GestureDetector( 
                onTap: ()async{
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                    return Detail(roomname,snapshot.data.docs[index].id);
                  }),
                );
              },
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text( 
                        snapshot.data.docs[index].data()['title']??'',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        snapshot.data.docs[index].data()['description']??'',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

//↑部屋一覧ページ↑

//↓部屋詳細ページ↓

class Detail extends StatelessWidget {
  Detail(this.roomname, this.id);
  String roomname;
  String id;
  @override
  Widget build(BuildContext context){
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail',
          style: TextStyle(
            color: Colors.black
          ),
        ),       
        backgroundColor: Colors.white,
        leading: IconButton(
        icon: Icon(
          Icons.close,
          color: Colors.black
        ),
        onPressed: () async {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) {
              return Room(roomname);
            }),
          );
        },
      ),
    ),
    body: SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            child: StreamBuilder (
              stream: FirebaseFirestore.instance.collection(roomname).doc(id).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading');
                }
                  return  Center(
                    child: Column(
                      children: [ 
                        Text(
                          'Title',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          snapshot.data['title']??'',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 40,
                          ),
                        ),
                      ]
                    ),
                  );
                },
              ),
            ),
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            child:  StreamBuilder(
              stream: FirebaseFirestore.instance.collection(roomname).doc(id).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading');
                }
                  return Center(
                    child: Column(
                      children:[
                        Text(
                          'Description',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          snapshot.data['description']??'',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ]
                    ),
                  );
                },
              ),
            ),
            SizedBox(
            height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child:  StreamBuilder(
                stream: FirebaseFirestore.instance.collection(roomname).doc(id).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading');
                  }
                    return Center(
                    child: Column(
                      children:[
                        Text(
                          'Budget',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          snapshot.data['budget']??'',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ]
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child:  Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:  StreamBuilder(
                  stream: FirebaseFirestore.instance.collection(roomname).doc(id).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading');
                    }
                      return Center(
                        child: Column(
                          children:[
                            Text(
                              'Contents',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              snapshot.data['contents']??'',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                          ]
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 20, right: 20),
                child: ElevatedButton(
                  child: Text(
                    'Joining',
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                  ),
                  onPressed: () async{
                    await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .set({
                        'roomname': roomname,
                        'room_id': id,
                      });
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return Top(roomname,id);
                        }),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

//↑部屋詳細ページ↑

//↓部屋作成ページ↓

class AddRoom extends StatefulWidget {
  AddRoom(this.roomname);
  String roomname;
  @override
  _AddRoomState createState() => _AddRoomState(roomname);
}

class _AddRoomState extends State<AddRoom> {
  _AddRoomState(this.roomname);
  String roomname;

  String title = '';
  String description = '';
  String budget = '';
  String contents = '';

  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Room',
          style: TextStyle(
            color: Colors.black
          ),
        ),
        leading: IconButton(
      icon: Icon(
        Icons.close,
        color: Colors.black
      ),
      onPressed: () async {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) {
          return Room(roomname);
          }),
        );
       },
      ),
      backgroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                  ),
                ),
                onChanged: (String value) {
                  setState(() {
                    title = value;
                  });
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                onChanged: (String value) {
                  setState(() {
                    description = value;
                  });
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Budget',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                  ),
                ),
                onChanged: (String value) {
                  setState(() {
                    budget = value;
                  });
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Contents',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 15,
                onChanged: (String value) {
                  setState(() {
                    contents = value;
                  });
                },
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('Create'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection(roomname)
                        .doc()
                        .set({
                      'title': title,
                      'description': description,
                      'budget': budget,
                      'contents': contents,
                        });
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//↑部屋作成ページ↑
//↓トップページ↓


class Top extends StatelessWidget {
  Top(this.roomname,this.id);
  String roomname;
  String id;
  @override
  Widget build(BuildContext context){
  final UserState userState = Provider.of<UserState>(context);
  final User user = userState.user;

    return Scaffold(
        appBar: AppBar(
                title:    StreamBuilder (
              stream: FirebaseFirestore.instance.collection(roomname).doc(id).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading');
                }
                  return Text(

          snapshot.data['title']??'',
          style: TextStyle(
            color: Colors.black
          ),
        );
              }
                    ),
              
        
      leading:IconButton(
        icon: Icon(
        Icons.logout,
        color: Colors.black
      ),
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) {
          return Login();
          }),
        );
       },
       ),
        actions: [IconButton(
        icon: Icon(
        Icons.notes,
        color: Colors.black
      ),
      onPressed: () async {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) {
          return JoinDetail(roomname,id);
          }),
        );
       },
       ),
       ],
        backgroundColor: Colors.white,
        ),
        body: JoinRoom(roomname,id),
    );
  }
}

class JoinRoom extends StatefulWidget {
      JoinRoom(this.roomname,this.id);
  String roomname;
  String id;

    @override
  JoinRoomState createState() => JoinRoomState(roomname,id);
}

class JoinRoomState extends State<JoinRoom> {
    JoinRoomState(this.roomname,this.id);
    String roomname;
  String id;
  String message = '';

  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user;
      final TextEditingController _textEditingController = new TextEditingController();
    return Scaffold(
      body: Column(
        children: [
               Expanded(
    child: StreamBuilder(
      stream: FirebaseFirestore.instance.collection('${roomname}/${id}/messages').orderBy('date', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading');
        }
      return ListView.builder(
        reverse: true,
        itemCount: snapshot.data.docs.length,
        itemBuilder: (context, index) {
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
  ),
  child: Container(
    padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                         Text(
            snapshot.data.docs[index].data()['name']??'',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 20,
            color: Colors.grey
          ),
          ),
           Text(
            snapshot.data.docs[index].data()['message']??'',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
          ),
         Text(
            snapshot.data.docs[index].data()['date']??'',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey
          ),
          ),
              ]
            ),
  ),
          );
        },
      );
    },
  ),

        ),
SafeArea(
  child: Container(
    margin: EdgeInsets.all(20),
    child: Row(
      children: [
         Flexible(
    child: TextField(
    controller: _textEditingController,
      autofocus: true,
      style: TextStyle(
        fontSize: 20.0,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: 'Message',
      ),
    ),
         ),
    IconButton(      icon: Icon(
        Icons.send,
        color: Colors.black
    
      ), onPressed: () async {
                            final date =DateTime.now().toLocal().toIso8601String(); // 現在の日時
                       final currentUser = await FirebaseAuth.instance.currentUser;
                    await FirebaseFirestore.instance
                        .collection('${roomname}/${id}/messages')
                        .doc()
                        .set({
                          'date': date,
                          'name': currentUser.displayName,
                      'message': _textEditingController.text,
                        });
  _textEditingController.clear();
      }
      )
    ]
    ),
  ),
),
        ]
      ),
    );
  }
}

//↑トップページ↑

//↓参加した部屋の詳細ページ↓

class JoinDetail extends StatelessWidget {
      JoinDetail(this.roomname,this.id);
      String roomname;
  String id;
  @override
  Widget build(BuildContext context){
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Detail',
        style: TextStyle(
          color: Colors.black
        ),
      ),       
      backgroundColor: Colors.white,
      leading: IconButton(
      icon: Icon(
        Icons.close,
        color: Colors.black
      ),
      onPressed: () async {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) {
          return Top(roomname,id);
          }),
        );
       },
      ),
    ),
    body: SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            child: StreamBuilder (
              stream: FirebaseFirestore.instance.collection(roomname).doc(id).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading');
                }
                  return  Center(
                    child: Column(
                      children: [ 
                        Text(
                          'Title',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          snapshot.data['title']??'',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 40,
                          ),
                        ),
                      ]
                    ),
                  );
                },
              ),
            ),
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            child:  StreamBuilder(
              stream: FirebaseFirestore.instance.collection(roomname).doc(id).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading');
                }
                  return Center(
                    child: Column(
                      children:[
                        Text(
                          'Description',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          snapshot.data['description']??'',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ]
                    ),
                  );
                },
              ),
            ),
            SizedBox(
            height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child:  StreamBuilder(
                stream: FirebaseFirestore.instance.collection(roomname).doc(id).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading');
                  }
                    return Center(
                    child: Column(
                      children:[
                        Text(
                          'Budget',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          "¥${snapshot.data['budget']??''}",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ]
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
          Expanded(
            child:  Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
              ),
              child:  StreamBuilder(
                stream: FirebaseFirestore.instance.collection(roomname).doc(id).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading');
                  }
                    return Center(
                      child: Column(
                        children:[
                          Text(
                            'Contents',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            snapshot.data['contents']??'',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                        ]
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//↑参加した部屋の詳細ページ↑ï