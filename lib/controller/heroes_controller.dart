import 'package:aqueduct/aqueduct.dart';
import 'package:heroes/heroes.dart';
import 'package:heroes/model/hero.dart';

class HeroesController extends ResourceController {
  
  HeroesController(this.context);

  final ManagedContext context; 
  
  // List<Map<String, Object>> get _heroes => [
  //   {'id': 11, 'name': 'Mr. Nice'},
  //   {'id': 12, 'name': 'Narco'},
  //   {'id': 13, 'name': 'Bombasto'},
  //   {'id': 14, 'name': 'Celeritas'},
  //   {'id': 15, 'name': 'Magneta'},    
  // ];

  // @Operation.get()
  // Future<Response> getAllHeroes() async {
  //   final heroQuery = Query<Hero>(context);
  //   final heroes = await heroQuery.fetch();

  //   return Response.ok(heroes);
  // }

  @Operation.get()
  Future<Response> getAllHeroes({@Bind.query('name') String name}) async {
    final heroQuery = Query<Hero>(context);
    if (name != null) {
      heroQuery.where((h) => h.name).contains(name, caseSensitive: false);
    }
    final heroes = await heroQuery.fetch();

    return Response.ok(heroes);
  }


  @Operation.get('id')
  Future<Response> getHeroByID(@Bind.path('id') int id) async {
    final heroQuery = Query<Hero>(context)
      ..where((h) => h.id).equalTo(id);    

    final hero = await heroQuery.fetchOne();

    if (hero == null) {
      return Response.notFound();
    }
    return Response.ok(hero);
  }
}