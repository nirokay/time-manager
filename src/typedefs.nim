import std/[asynchttpserver, asyncdispatch]
type
    ServerResponse* = object
        code*: HttpCode
        content*: string
