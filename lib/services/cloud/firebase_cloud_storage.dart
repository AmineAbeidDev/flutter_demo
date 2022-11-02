import 'package:notes/services/cloud/cloud_storage_exceptions.dart';
import 'package:notes/services/cloud/cloud_storage_constants.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  //********** SINGLETON **********//
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  Future<CloudNote> createNewNotes({required String ownerUserId}) async {
    final documnet = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    //! document is only a refrence and we need to use get() to actually read the data
    final fetchedNote = await documnet.get();
    return CloudNote(
        documentId: fetchedNote.id, ownerUserId: ownerUserId, text: '');
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map((doc) => CloudNote.fromSnapShot(doc)),
          );
      //! Where returns the query, and you need to execute it by
      //! invoking get(); to return a querySnapshot with all the
      //! objects from firestore.
      //! then() allows you to return a synchronys data or a future
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  //! Snapshot gets a collection with the latest update

  //! First we're mapping the docs in snapshot to a cloudNote
  //! object, then we get the docs of the userId only
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapShot(doc))
          .where((note) => note.ownerUserId == ownerUserId));

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }
}
