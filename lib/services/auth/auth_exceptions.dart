
// login exceptions
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}


// registeration exceptions
class WeakPasswordAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}


// generic exceptions
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}