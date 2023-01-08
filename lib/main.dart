import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool statusLogin = false;
  late User userdata;
  final String email = 'amolina@hotmail.com';
  final String passw = 'passwluis';
  @override
  initState() {
    status();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: Scaffold(
        appBar: statusLogin
            ? AppBar(
                title: FittedBox(child: Text('Bienvenido ${userdata.uid}')),
                actions: [
                  IconButton(
                      onPressed: (() async =>
                          await FirebaseAuth.instance.signOut()),
                      icon: const Icon(Icons.exit_to_app))
                ],
              )
            : AppBar(
                title: const Text('Por favor inicie sesión'),
              ),
        body: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              statusLogin
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator()),
                    )
                  : ButtonLogin(
                      email: email,
                      passw: passw,
                    ),
              ButtonAdd(email: email, passw: passw),
              statusLogin
                  ? ButtonDelete(
                      email: email,
                      password: passw,
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                          'No puedo eliminar un usuario que no esta logueado.'),
                    ),
              statusLogin
                  ? const ButtonUpdate()
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                          'No puedo actualizar un usuario que no esta logueado.'),
                    ),
              statusLogin
                  ? ButtonUpdateEmail(email: email, passw: passw)
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                          'No puedo actualizar el correo de un usuario no logueado.'),
                    ),
              statusLogin
                  ? const Buttonverified()
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                          'No puedo verificar el correo de un usuario no logueado.'),
                    ),
            ],
          )),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            User? user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              log(user.toString());
            }
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  status() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        log('Usuario iniciado con UID:${user.uid}');
        statusLogin = true;
        userdata = user;
      } else {
        statusLogin = false;
        log(name: '...', 'No se a encontrado un usuario con sesión iniciada');
        // log('userdata=> ${userdata.email}');
      }
      setState(() {});
      log(name: 'initState=> ', 'User con sesión iniciada=> $statusLogin');
    });
  }
}

class ButtonLogin extends StatelessWidget {
  final String email;
  final String passw;
  const ButtonLogin({
    Key? key,
    required this.email,
    required this.passw,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.teal,
        width: 200,
        child: IconButton(
          onPressed: () async {
            try {
              await FirebaseAuth.instance
                  .signInWithEmailAndPassword(email: email, password: passw);
            } on FirebaseAuthException catch (e) {
              if (e.code == 'user-not-found') {
                log('No user found for that email.');
              } else if (e.code == 'wrong-password') {
                log('Wrong password provided for that user.');
              }
            }
          },
          icon: const Icon(Icons.login),
        ));
  }
}

class ButtonUpdateEmail extends StatelessWidget {
  final String email;
  final String passw;
  const ButtonUpdateEmail({
    Key? key,
    required this.email,
    required this.passw,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.green,
        width: 200,
        child: IconButton(
            onPressed: () async {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                AuthCredential credential =
                    EmailAuthProvider.credential(email: email, password: passw);
                UserCredential userCredential =
                    await user.reauthenticateWithCredential(credential);

                await userCredential.user?.updateEmail("pepeLuis555@gmail.com");
                log(name: 'Exito', 'user correo actualizado');
              } else {
                log(
                    name: 'Error',
                    'No se a podido actualizar  el correo del  user...');
              }
            },
            icon: const Icon(Icons.system_update_alt_sharp)));
  }
}

class Buttonverified extends StatelessWidget {
  const Buttonverified({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.yellow,
        width: 200,
        child: IconButton(
            onPressed: () async {
              final User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await user.sendEmailVerification();
                log('Se a enviado un correo de verificación...');
              } else {
                log(name: 'ERROR', 'No se a enviado el correo...');
              }
            },
            icon: const Icon(Icons.verified)));
  }
}

class ButtonUpdate extends StatelessWidget {
  const ButtonUpdate({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.orange,
        width: 200,
        child: IconButton(
            onPressed: () async {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await user.updateDisplayName("Pepe Lucho Mesa");
                await user.updatePhotoURL(
                    "https://www.firebaseauth.com/pepe-lucho-user/profile.jpg");
              }
            },
            icon: const Icon(Icons.update)));
  }
}

class ButtonDelete extends StatelessWidget {
  final String email;
  final String password;
  const ButtonDelete({
    Key? key,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final prov = Provider.of<ProviderAuth>(context);
    return Container(
        color: Colors.red,
        width: 200,
        child: IconButton(
            onPressed: () async {
              // Volvemos a verificar el usuario
              User? user = FirebaseAuth.instance.currentUser;
              //Si el usuario verificado existe
              if (user != null) {
                try {
                  AuthCredential credential = EmailAuthProvider.credential(
                      email: email, password: password);
                  UserCredential userCredential =
                      await user.reauthenticateWithCredential(credential);
                  await userCredential.user?.delete();
                  log(name: 'Exito', 'user eliminado');
                } catch (e) {
                  log('Error $e');
                }
              } else {
                log(name: 'Error', 'No se a encontrado un usuario.');
              }
            },
            icon: const Icon(Icons.delete)));
  }
}

class ButtonAdd extends StatelessWidget {
  final String email;
  final String passw;
  // final ProviderAuth provider;

  const ButtonAdd({
    Key? key,
    required this.email,
    required this.passw,
    // required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final prov = Provider.of<ProviderAuth>(context);
    return Container(
        color: Colors.blue,
        width: 200,
        child: IconButton(
            onPressed: () {
              log('$email / $passw');
              createuser(email: email, password: passw);
            },
            icon: const Icon(Icons.add)));
  }

  Future<void> createuser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        log('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        log('The account already exists for that email.');
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
