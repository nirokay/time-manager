import std/[os, strformat]
import cattag
import cssstuff

proc embedJS(document: var HtmlDocument, file: string) =
    let
        path: string = "docs" / "javascript" / file & ".js"
        content: string = path.readFile()
    document.addToHead(script(true, content))

const
    days: array[7, string] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    idUsername: string = "id-input-username"
    idPrefixDay: string = "id-day-"
    idTimeZone: string = "id-timezone"

    idValidateZone: string = "id-validate-zone"

proc idDay(str: string): string = idPrefixDay & str
proc idDayAvailable(str: string): string = idPrefixDay & str & "-available"
proc idDayStart(str: string): string = idPrefixDay & str & "-time-start"
proc idDayEnd(str: string): string = idPrefixDay & str & "-time-end"

proc day(name: string): HtmlElement =
    let
        idStart: string = idDayStart(name)
        idEnd: string = idDayEnd(name)

    result = `div`(
        details(false,
            summary(html name),
            p(
                html &"Times for {name}.",
                br(),
                html "Remember to use",
                strong(html"24h timeformat!")
            ),
            section(
                label(@["for" <=> idStart], html"Start time:"),
                input(@["type" <=> "time", "id" <=> idStart]),
            ),
            section(
                label(@["for" <=> idEnd], html"End time:"),
                input(@["type" <=> "time", "id" <=> idEnd]),
            )
        )
    ).setClass(classDayDiv.selector)

proc getHtmlIndex(): HtmlDocument =
    result = newHtmlDocument("index.html")
    result.embedJS("index")
    result.addToHead(
        title(html"Time Manager"),
        style(html stylesheet)
    )
    result.add(
        h1(html"Time Manager"),
        h2(html"Personal details and Timezone"),
        `div`(
            section(
                label(@["for" <=> idUsername], html"Your username:"),
                input(@["type" <=> "text", "id" <=> idUsername, "placeholder" <=> "Your name"]),
            ),
            section(
                label(@["for" <=> idTimezone], html"Your timezone (UTC offset):"),
                input(@["type" <=> "number", "id" <=> idTimezone, "placeholder" <=> "+2"])
            )
        ).setClass(classDayDiv.selector)
    )

    result.add h2(html"Days")
    result.add p(html"If you are not free on the day, skip it.")
    for d in days:
        result.add day(d)
    result.add button("button", html"Validate input").add("onclick" <=> "handleSubmitValidate()")

    result.add(
        section(
            h2(html"Validate your inputs"),
            `div`(html"none").setClass(classDayDiv.selector).setId(idValidateZone),
            button("button", html"Send away!").add("onclick" <=> "handleSubmitSend()")
        ).setId(idValidateSection)
    )


const
    htmlPageIndex*: string = $getHtmlIndex()

when not defined release:
    writeFile("index.html", htmlPageIndex)
