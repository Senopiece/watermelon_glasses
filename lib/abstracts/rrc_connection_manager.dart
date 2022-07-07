import 'connection_manager.dart';
import 'rrc.dart';

/// classes extended from here undertake to use ConnectedRRC
class RrcConnectionManager extends ConnectionManager {}

class ConnectedRRC extends Connected {
  RRC get rrc => throw UnimplementedError();
}
