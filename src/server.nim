import std/[asynchttpserver, asyncdispatch, strutils]
import typedefs, htmlstuff

const port* {.intdefine.} = 42069

proc handleRequest(request: Request) {.async.} =
    let
        url = request.url
        urlParts: seq[string] = block:
            let r: seq[string] = url.path.split("/")
            r[1 .. ^1]
        page: string = urlParts[0]


    echo urlParts

    let response: ServerResponse = block:
        if page in ["", "index", "index.html"]:
            ServerResponse(
                code: Http200,
                content: htmlPageIndex
            )
        else:
            ServerResponse(
                code: Http404,
                content: "404: Not found"
            )

    let headers = {"Content-type": "text/html; charset=utf-8"}
    await request.respond(response.code, response.content, headers.newHttpHeaders())

proc runServer() {.async.} =
    var server: AsyncHttpServer = newAsyncHttpServer()
    server.listen(Port port)

    while true:
        if server.shouldAcceptRequest(): await server.acceptRequest(handleRequest)
        else: await sleepAsync(500)

waitFor runServer()
