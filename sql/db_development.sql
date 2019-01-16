CREATE DATABASE heroes;
CREATE USER heroes_user WITH createdb;
ALTER USER heroes_user WITH password 'password';
GRANT all ON database heroes TO heroes_user;