# TimeManager

## About

TimeManager is a simple webserver that saves user-submitted inputs to a SQLite database.
Users are prompted to put in their username, timezone and free-time - this helps with
coordinating events or other similar stuff, especially across multiple timezones.

Why not use a tool like Google Surveys? Uhm, idk... more control over your data??
Also fuck Google :3

## Compiling and Running

`nimble compilerun` or `tsc && nimble run`

If you are hosting this, please use a reverse proxy and do not have the impression my
code is perfect, you probably will get hacked, get your data stolen and your server
blown up!

### Compilation Dependency

* **Nim** (Nim version >= 2.0.0), and the following libraries:
  * nimble: *db_connector* (Database stuff)
  * nimble: *CatTag* (HTML/CSS)
  * external: *libpcre1* [OpenSUSE](https://software.opensuse.org/download/package?package=libpcre1&project=Base%3ASystem)
* **TypeScript Compiler**

## License

All code is published under the **GNU General Public License 3.0**.
