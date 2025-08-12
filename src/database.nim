import std/[asynchttpserver, asyncdispatch, options, uri, base64, json]
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
    finally:
        if success: db.exec(sql"COMMIT")
        db.close()


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
                if decodedUri == "": i(html"empty") else: pre(html decodedUri)
            ),
            p(
                html"Decoded from Base64:",
                if decoded == "": i(html"empty") else: pre(html decoded)
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
                pre(html decoded)
            )
        )
    )

    let userInput: UserInput = get parseResult.result
