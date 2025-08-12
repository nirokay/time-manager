import std/[asynchttpserver, asyncdispatch, strutils]
import typedefs, htmlstuff, database

const port* {.intdefine.} = 42069

proc handleRequest(request: Request) {.async, gcsafe.} =
    let
        headers = {"Content-type": "text/html; charset=utf-8"}
        url = request.url
        urlParts: seq[string] = block:
            let r: seq[string] = url.path.split("/")
            r[1 .. ^1]
        page: string = urlParts[0]

    var response: ServerResponse = ServerResponse(
        code: Http501,
        content: htmlPageNotImplemented
    )
    try:
        response = block:
            if page in ["", "index", "index.html"]:
                # Index:
                ServerResponse(
                    code: Http200,
                    content: htmlPageIndex
                )
            elif page in ["submit"]:
                # Submit:
                let
                    payload: string = block:
                        if urlParts.len() < 2: ""
                        else: urlParts[1]
                    response: ServerResponse = handlePayloadSubmission(payload)
                response
            else:
                # Generic 404:
                ServerResponse(
                    code: Http404,
                    content: htmlPage404
                )
    except CatchableError as e:
        response = ServerResponse(
            code: Http500,
            content: htmlPageException(e.name, e.msg)
        )
    except Defect as e:
        response = ServerResponse(
            code: Http500,
            content: htmlPageException(e.name, e.msg)
        )

    await request.respond(response.code, response.content, headers.newHttpHeaders())

proc runServer() {.async.} =
    echo "Running server..."
    initDatabase()
    var server: AsyncHttpServer = newAsyncHttpServer()
    server.listen(Port port)

    while true:
        if server.shouldAcceptRequest(): await server.acceptRequest(handleRequest)
        else: await sleepAsync(500)

waitFor runServer()
