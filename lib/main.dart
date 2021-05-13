import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter/src/widgets/text.dart';



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

var _hasPadding = false;
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
      padding: EdgeInsets.all(_hasPadding ? 10 : 0),
        child: GestureDetector(
                  onTapDown: (TapDownDetails downDetails) {
          setState(() {
            _hasPadding = true;
          });
        },
            onTap: ()async{
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return Room();
                }),
              );
            },
            child: Container(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
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
          Container(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: 0.8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('images/volcano.jpeg', fit: BoxFit.cover,)
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
          Container(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: 0.8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('images/desert.jpeg', fit: BoxFit.cover,)
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
          Container(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: 0.8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('images/jungle.jpeg', fit: BoxFit.cover,)
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
          Container(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: 0.8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('images/snow mountain.jpeg', fit: BoxFit.cover,)
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
          Container(
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
          Container(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: 0.8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('images/deep sea.jpeg', fit: BoxFit.cover,)
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
          Container(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: 0.8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('images/earth.webp', fit: BoxFit.cover,)
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
        ]
      ),
    );
  }
}



class Room extends StatelessWidget {
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
        body: RoomList(),
        floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddRoom();
            }),
          );
        },
      ),
      
    );
  }
}

class RoomList extends StatelessWidget {
  @override
  Widget build(BuildContext context){
  final UserState userState = Provider.of<UserState>(context);
  final User user = userState.user;

    CollectionReference aurora = FirebaseFirestore.instance.collection('aurora rooms');
    return StreamBuilder<QuerySnapshot>(
      stream: aurora.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading');
        }



 return  ListView(
          children:  snapshot.data.docs.map((DocumentSnapshot document) {
            return GestureDetector( 
              onTap: ()async{
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return Detail();
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
                        document.data()['title']??'default value',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        document.data()['description']??'default value',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}



class Detail extends StatelessWidget {
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
          return Room();
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
              stream: FirebaseFirestore.instance.collection('aurora rooms').doc('tu5gcNAWOh9EHYUSXS3M').snapshots(),
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
                          snapshot.data['title'],
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
              stream: FirebaseFirestore.instance.collection('aurora rooms').doc('tu5gcNAWOh9EHYUSXS3M').snapshots(),
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
                          snapshot.data['description'],
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
                stream: FirebaseFirestore.instance.collection('aurora rooms').doc('tu5gcNAWOh9EHYUSXS3M').snapshots(),
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
                          "¥${snapshot.data['budget'].toString()}",
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
                stream: FirebaseFirestore.instance.collection('aurora rooms').doc('tu5gcNAWOh9EHYUSXS3M').snapshots(),
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
                            snapshot.data['contents'],
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
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return Top();
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


class AddRoom extends StatefulWidget {
  AddRoom();

  @override
  _AddRoomState createState() => _AddRoomState();
}

class _AddRoomState extends State<AddRoom> {

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
          return Room();
          }),
        );
       },
      ),
      backgroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
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
                        .collection('aurora rooms')
                        .doc()
                        .set({
                      'title': title,
                      'description': description,
                      'budget': budget,
                      'contents': contents,
                        });
                    // 1つ前の画面に戻る
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


class Top extends StatelessWidget {
  @override
  Widget build(BuildContext context){
  final UserState userState = Provider.of<UserState>(context);
  final User user = userState.user;

    return Scaffold(
        appBar: AppBar(
        title: Text(
          'Adventure',
          style: TextStyle(
            color: Colors.black
          ),
        ),
      leading: Container( 
        width: 100,
       child: TextButton(
      child: Text(
        'Sign Out',
        style: TextStyle(
          color: Colors.black,
        ),
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
       ),
        backgroundColor: Colors.white,
        ),
        body: JoinRoom(),
    );
  }
}

class JoinRoom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:  SafeArea(
        child:  GestureDetector( 
                      onTap: ()async{
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return JoinDetail();
                }),
              );
            },
        child: Container(
                    height: 150,
            margin: EdgeInsets.only(top: 20, left: 20,right: 20),
          child:Stack(
            fit: StackFit.expand,
            children: [
                  Opacity(
                  opacity: 0.8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('images/aurora.jpg', fit: BoxFit.cover,)
                  ),
                ),
             StreamBuilder (
              stream: FirebaseFirestore.instance.collection('aurora rooms').doc('tu5gcNAWOh9EHYUSXS3M').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading');
                }
                  return  Center(
                      child:  
                        Text(
                          snapshot.data['title'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 40,
                          ),
                        ),
                  );
                },
              
              ),
            ]
          ),
        ),
      ),
        ),
    );

  }
  }

class JoinDetail extends StatelessWidget {
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
          return Room();
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
              stream: FirebaseFirestore.instance.collection('aurora rooms').doc('tu5gcNAWOh9EHYUSXS3M').snapshots(),
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
                          snapshot.data['title'],
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
              stream: FirebaseFirestore.instance.collection('aurora rooms').doc('tu5gcNAWOh9EHYUSXS3M').snapshots(),
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
                          snapshot.data['description'],
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
                stream: FirebaseFirestore.instance.collection('aurora rooms').doc('tu5gcNAWOh9EHYUSXS3M').snapshots(),
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
                          "¥${snapshot.data['budget'].toString()}",
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
                stream: FirebaseFirestore.instance.collection('aurora rooms').doc('tu5gcNAWOh9EHYUSXS3M').snapshots(),
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
                            snapshot.data['contents'],
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
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return Top();
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