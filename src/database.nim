import std/[asynchttpserver, asyncdispatch, strformat, options, uri, base64, json, times, tables]
import db_connector/db_sqlite
import cattag
import typedefs, htmlstuff

const dbName {.strdefine.}: string = "database.db"

proc getDatabase(): DbConn = open(dbName, "", "", "")
template withDatabase*(db: untyped, body: untyped): untyped =
    ## Template to avoid writing repetitive code
    let db: DbConn = getDatabase()
    db.exec(sql"BEGIN TRANSACTION")
    var success: bool = true
    try:
        body
        success = true
    except CatchableError as e:
        success = false
        echo &"Database error '" & $e.name & "':\n -> " & e.msg
    finally:
        if success: db.exec(sql"COMMIT")
        db.close()

proc initDatabase*() =
    withDatabase db:
        db.exec(sql"""
            CREATE TABLE IF NOT EXISTS inputs (
                timestamp INTEGER PRIMARY KEY UNIQUE NOT NULL,
                username WORD NOT NULL,
                timezone INTEGER NOT NULL DEFAULT 0,
                monday WORD,
                tuesday WORD,
                wednesday WORD,
                thursday WORD,
                friday WORD,
                saturday WORD,
                sunday WORD
            );
        """)

proc success(): (bool, string) = (true, "")
proc failure(reason: string): (bool, string) = (false, reason)
proc toDbRepr(times: array[2, string]): string =
    let
        timeStart: string = times[0]
        timeEnd: string = times[1]
    result = block:
        if timeStart == "" and timeEnd == "": ""
        else: &"{timeStart}-{timeEnd}"
proc submitRequest(data: UserInput): (bool, string) =
    let timestamp: int = int(epochTime() * 1000)
    try:
        var id: int = -1
        withDatabase db:
            id = db.tryInsert(
                sql"""
                    INSERT INTO inputs (
                        timestamp,
                        username,
                        timezone,
                        monday,
                        tuesday,
                        wednesday,
                        thursday,
                        friday,
                        saturday,
                        sunday
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
                """,
                $timestamp,
                timestamp,
                data.username,
                data.timezone,
                data.times[Monday].toDbRepr(),
                data.times[Tuesday].toDbRepr(),
                data.times[Wednesday].toDbRepr(),
                data.times[Thursday].toDbRepr(),
                data.times[Friday].toDbRepr(),
                data.times[Saturday].toDbRepr(),
                data.times[Sunday].toDbRepr(),
            )
        if id == -1: return failure("Failed to insert into database.")
        else: return success()
    except DbError as e:
        return failure(&"{e.name}: {e.msg}")


proc handlePayloadSubmission*(payload: string): ServerResponse =
    if payload == "": return ServerResponse(
        code: Http400,
        content: htmlPageFailure(p(html"Empty payload."))
    )
    let
        decodedUri: string = block:
            try:
                payload.decode()
            except ValueError:
                ""
        decoded: string = block:
            try:
                decodedUri.decodeUrl()
            except CatchableError:
                ""
    if unlikely decoded == "": return ServerResponse(
        code: Http400,
        content: htmlPageFailure(
            p(html"Malformed payload."),
            p(
                html"Decoded from URI:",
                if decodedUri == "": i(html"empty") else: code(html decodedUri)
            ),
            p(
                html"Decoded from Base64:",
                if decoded == "": i(html"empty") else: code(html decoded)
            )
        )
    )

    let parseResult: Result[UserInput] = parseUserInput(decoded)
    if parseResult.error: return ServerResponse(
        code: Http400,
        content: htmlPageFailure(
            p(
                html"JSON data seems to be invalid. Reason:",
                html parseResult.message,
                br(),
                html"Parsed JSON:",
                br(),
                code(html decoded)
            )
        )
    )

    let userInput: UserInput = get parseResult.result
    try:
        let (status, reason) = submitRequest(userInput)
        if unlikely(not status):
            return ServerResponse(
                code: Http500,
                content: htmlPageException("Database Problem", reason)
            )
    except CatchableError as e:
        return ServerResponse(
            code: Http500,
            content: htmlPageException(e.name, e.msg)
        )
    result = ServerResponse(
        code: Http200,
        content: htmlPageSuccess
    )
