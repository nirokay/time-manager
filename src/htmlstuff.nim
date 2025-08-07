import std/[strutils, strformat]
import cattag

const
    days: array[7, string] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    idUsername: string = "id-input-username"
    idPrefixDay: string = "id-day-"
    idTimeZone: string = "id-timezone"

proc idDay(str: string): string = idPrefixDay & str
proc idDayAvailable(str: string): string = idPrefixDay & str & "-available"
proc idDayStart(str: string): string = idPrefixDay & str & "-time-start"
proc idDayEnd(str: string): string = idPrefixDay & str & "-time-end"

proc day(name: string): HtmlElement =
    let
        idStart: string = idDayStart(name)
        idEnd: string = idDayEnd(name)

    result = section(
        h3(html name),
        p(html &"Times for {name}.\nIf you are not free on this day, skip this. Remember to use <strong>24h timeformat</strong>!"),
        section(
            label(@["for" <=> idStart], html"Start time:"),
            input(@["type" <=> "time", "id" <=> idStart]),
        ),
        section(
            label(@["for" <=> idEnd], html"End time:"),
            input(@["type" <=> "time", "id" <=> idEnd]),
        )
    )

proc getHtmlIndex(): HtmlDocument =
    result = newHtmlDocument("index.html")
    result.addToHead(
        title(html"Time Manager")
    )
    result.add(
        h1(html"Time Manager"),
        section(
            label(@["for" <=> idUsername], html"Your username:"),
            input(@["type" <=> "text", "id" <=> idUsername, "placeholder" <=> "Your name"]),
        ),
        section(
            label(@["for" <=> idTimezone], html"Your timezone (UTC offset):"),
            input(@["type" <=> "number", "id" <=> idTimezone, "placeholder" <=> "+2"])
        )
    )

    for d in days:
        result.add day(d)


const
    htmlPageIndex*: string = $getHtmlIndex()

writeFile("index.html", htmlPageIndex)
