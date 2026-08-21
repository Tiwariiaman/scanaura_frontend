import 'qr_file_helper_stub.dart'
if (dart.library.html) 'qr_file_helper_web.dart'
if (dart.library.io) 'qr_file_helper_io.dart';

export 'qr_file_helper_stub.dart'
if (dart.library.html) 'qr_file_helper_web.dart'
if (dart.library.io) 'qr_file_helper_io.dart';