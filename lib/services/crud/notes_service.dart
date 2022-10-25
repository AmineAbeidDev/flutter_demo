import 'package:notes/services/crud/crud_exceptions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'dart:async';

class NotesService {
  Database? _db; //* creates an sqlite database

  List<DatabaseNotes> _notes = [];

  //************ SINGLETON ************//
  static final NotesService _shared = NotesService
      ._sharedInstance(); //*creates a static object (initialized only once)
  NotesService._sharedInstance() {
    //*private named constructor
    _notesStreamController = StreamController<List<DatabaseNotes>>.broadcast(
      //* Creates a stream controller
      onListen: () {
        //gets called whenever a new listener subs to the strmCtrl's stream
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  /*  STREAMS ~ BROADCAST
  *   .broadcast() is a stream controller which allows to listen
  *   to a stream more than once by many listeners, each listeners
  *   actions are limited to him and do not affect other listeners
  *   or the stream as a whole.
  ?   by Listener i mean widget */

  factory NotesService() => _shared;
  /*  SINGLETON
  *   now only one instance of the NotesService is gonna be
  *   created and shared whenever you you create a new pbject
  *   with NotesService(). */

  /*  STREAMS
  *   Streams are a flow of various types of data event waiting
  *   for listeners to grab it. Streams can also send errors in
  *   addition of data. */
  late final StreamController<List<DatabaseNotes>> _notesStreamController;

  Stream<List<DatabaseNotes>> get allNotes => _notesStreamController.stream;

//! ********** NOTE ********** !//
  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList(); //* adds notes to the local list/storage
    _notesStreamController.add(_notes); //* sends an event to the stream
  }

  Future<DatabaseNotes> updateNote({
    required DatabaseNotes note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //Make sure note exists
    await getNote(id: note.id);

    //* Updates the DB
    final updateCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: false,
    });

    if (updateCount == 0) {
      throw CouldNotUpdateNoteException();
    } else {
      //* Updates the list
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      //* Updates the stream
      _notesStreamController.add(_notes);
      return (updatedNote);
    }
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);

    //* Creates a map out of the list and returns an iterable of notesDb
    return (notes.map((noteRow) => DatabaseNotes.fromRow(noteRow)));
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      final note = DatabaseNotes.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return (note);
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numOfDels = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return (numOfDels);
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDelNoteException();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) throw CouldNotDelUsrException();

    const text = '';
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });
    final note = DatabaseNotes(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

//! ********** USER ********** !//
  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return (user);
    } on CouldNotFindUsrException {
      final createdUser = await createUser(email: email);
      return (createdUser);
    } catch (e) {
      rethrow;
    }
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw (CouldNotFindUsrException());
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) throw UsrAlreadyExistsException();

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    ); //as long as where is equal to whereArgs delete
    if (deletedCount == 0) throw CouldNotDelUsrException();
  }

//! ********** DATABASE ********** !//
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DbNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DbNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DbAlreadyOpenException {}
  }

  Future<void> open() async {
    if (_db != null) throw DbAlreadyOpenException();

    try {
      //* creates a splite Database in the dir hiarchy then opens it
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      //* executes the sqlite code to creates the user & notes tables
      await db.execute(createUserTable);
      await db.execute(createNoteTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocsDirException();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;

  // covariant changes the behavior of the input parameter so they
  // do not conform to the signature of that parameter in the superclass
}

class DatabaseNotes {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNotes({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 0 ? false : true;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';

  @override
  bool operator ==(covariant DatabaseNotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable =
    '''CREATE TABLE IF NOT EXISTS "user" ("id"	INTEGER NOT NULL, "email"	TEXT NOT NULL UNIQUE, PRIMARY KEY("id" AUTOINCREMENT));''';
const createNoteTable =
    '''CREATE TABLE IF NOT EXISTS "note" ("id"	INTEGER NOT NULL, "user_id"	INTEGER NOT NULL, "text"	TEXT, "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0, PRIMARY KEY("id" AUTOINCREMENT), FOREIGN KEY("user_id") REFERENCES "user"("id"));''';
