CREATE DATABASE dart_test;
CREATE USER dart WITH createdb;
ALTER USER dart WITH password 'dart';
GRANT all ON database dart_test TO dart;