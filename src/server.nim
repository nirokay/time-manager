import std/[asynchttpserver, asyncdispatch, strutils]
import typedefs, htmlstuff, database

const port* {.intdefine.} = 42069

proc handleRequest(request: Request) {.async, gcsafe.} =
    let
        url = request.url
        urlParts: seq[string] = block:
            let r: seq[string] = url.path.split("/")
            r[1 .. ^1]
        page: string = urlParts[0]

    let response: ServerResponse = block:
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

    let headers = {"Content-type": "text/html; charset=utf-8"}
    await request.respond(response.code, response.content, headers.newHttpHeaders())

proc runServer() {.async.} =
    echo "Running server..."
    var server: AsyncHttpServer = newAsyncHttpServer()
    server.listen(Port port)

    while true:
        if server.shouldAcceptRequest(): await server.acceptRequest(handleRequest)
        else: await sleepAsync(500)

waitFor runServer()
