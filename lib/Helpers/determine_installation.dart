import 'package:path_provider/path_provider.dart';

Future<String?> getInstallation() async {
  return (await getApplicationSupportDirectory()).path;

  /* if (Platform.isWindows) {
    var userDirectoryProcess =
        await Process.run('echo', ['%USERPROFILE%'], runInShell: true);
    var userDirectoryNT = userDirectoryProcess.stdout.toString().trim();
    var userDirectory = userDirectoryNT.replaceAll(r'\', '/');
    if (!userDirectory.endsWith("/")) {
      userDirectory += "/";
    }

    return userDirectory + "AppData/Local/Minepicker/";
  } else if (Platform.isMacOS) {
    var userDirectoryProcess =
        await Process.run('whoami', [], runInShell: true);
    var userDirectory =
        "/Users/" + userDirectoryProcess.stdout.toString().trim();

    return "$userDirectory/Library/Application Support/minepicker/";
  } */
}
