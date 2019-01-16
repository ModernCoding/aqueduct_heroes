import 'package:aqueduct/managed_auth.dart' show ManagedAuthDelegate;
import 'package:heroes/controller/heroes_controller.dart' show HeroesController;
import 'package:heroes/controller/register_controller.dart' show RegisterController;
import 'package:heroes/model/user.dart' show User;

import 'heroes.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class HeroesChannel extends ApplicationChannel {
  
  ManagedContext context;
  AuthServer authServer;

  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final HeroConfig config = HeroConfig(options.configurationFilePath);
    final ManagedDataModel dataModel = ManagedDataModel.fromCurrentMirrorSystem();

    final PostgreSQLPersistentStore persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        config.database.username,
        config.database.password,
        config.database.host,
        config.database.port,
        config.database.databaseName
      );

    context = ManagedContext(dataModel, persistentStore);

    final ManagedAuthDelegate<User> authStorage = ManagedAuthDelegate<User>(context);
    authServer = AuthServer(authStorage);
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint => Router()

    // Prefer to use `link` instead of `linkFunction`.
    // See: https://aqueduct.io/docs/http/request_controller/
    
    // ..route('/heroes')
    //   .link(() => HeroesController())
    ..route('/auth/token')
      .link(() => AuthController(authServer))

    ..route('/heroes/[:id]')
      .link(() => Authorizer.bearer(authServer))
      .link(() => HeroesController(context))

    ..route('/register')
      .link(() => RegisterController(context, authServer))

    ..route("/example")
      .linkFunction((request) async {
        return Response.ok({"key": "value"});
      })
    
    ;
}


class HeroConfig extends Configuration {
  HeroConfig(String path): super.fromFile(File(path));

  DatabaseConfiguration database;
}