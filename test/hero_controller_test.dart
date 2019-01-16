import 'package:heroes/model/hero.dart';

import 'harness/app.dart';

void main() {
  final Harness harness = Harness()..install();

  test("GET /heroes returns 200 OK", () async {
    final Query<Hero> query = Query<Hero>(harness.application.channel.context)
      ..values.name = "Bob";

    await query.insert();

    final TestResponse response = await harness.agent.get("/heroes");

    expectResponse(response, 200,
        body: allOf([
          hasLength(greaterThan(0)),
          everyElement({
            "id": greaterThan(0),
            "name": isString,
          })
        ])
      );
  });

  test("POST /heroes returns 200 OK", () async {
    final response = await harness.agent.post("/heroes", body: {
      "name": "Fred"
    });

    expectResponse(response, 200, body: {
      "id": greaterThan(0),
      "name": "Fred"
    });
  });

  test("POST /heroes returns 409 KO", () async {
    await harness.agent.post("/heroes", body: {
      "name": "Fred"
    });

    final badResponse = await harness.agent.post("/heroes", body: {
      "name": "Fred"
    });
    expectResponse(badResponse, 409);
  });
}