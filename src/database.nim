import std/[asynchttpserver, asyncdispatch, strutils]
import db_connector/db_sqlite
import cattag
import typedefs, htmlstuff

proc handlePayloadSubmission*(payload: string): ServerResponse =
    if payload == "": return ServerResponse(
        code: Http400,
        content: htmlPageFailure(p(html"Empty payload."))
    )
