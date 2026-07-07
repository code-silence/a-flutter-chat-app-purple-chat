import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PresenceRepository {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance.ref();

  Future<void> setOnline() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _db.child('users/${user.uid}');

    await userRef.child('isOnline').set(true);
    await userRef.child('lastSeen').set(ServerValue.timestamp);

    await userRef.child('isOnline').onDisconnect().set(false);
    await userRef.child('lastSeen').onDisconnect().set(ServerValue.timestamp);
  }

  Future<void> setOffline() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.child('users/${user.uid}/isOnline').set(false);
    await _db.child('users/${user.uid}/lastSeen').set(ServerValue.timestamp);
  }
}
