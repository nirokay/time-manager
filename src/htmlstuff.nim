import std/[os, strformat, sequtils]
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

proc getHtml404(): HtmlDocument =
    result = newHtmlDocument("404.html")
    result.addToHead(
        title(html"404 - Time Manager"),
        style(html stylesheet)
    )
    result.add(
        h1(html"404: Not found"),
        p(
            html"The page you requested does not exist :/",
            br(),
            a("/", "Click me to return to the main page!")
        )
    )

proc getHtmlSuccess(): HtmlDocument =
    result = newHtmlDocument("success.html")
    result.addToHead(
        title(html"Success - Time Manager"),
        style(html stylesheet)
    )
    result.add(
        h1(html"Request successful!"),
        p(
            html"Thank you, your input is received and saved.",
            br(),
            html"You may now close this page :)"
        )
    )

proc getHtmlFailure(reason: varargs[HtmlElement]): HtmlDocument =
    let reasonElements: seq[HtmlElement] = block:
        let r: seq[HtmlElement] = reason.toSeq()

        if r.len() == 0: @[p(html"Unspecified error.")]
        else: r

    result = newHtmlDocument("failure.html")
    result.addToHead(
        title(html"Failure - Time Manager"),
        style(html stylesheet)
    )
    result.add(
        h1(html"Request failed!"),
        p(html"Your request has failed with reason:")
    )
    result.add(reasonElements)

const
    htmlPageIndex*: string = $getHtmlIndex()
    htmlPage404*: string = $getHtml404()

    htmlPageSuccess*: string = $getHtmlSuccess()
proc htmlPageFailure*(reason: varargs[HtmlElement]): string {.gcsafe.} = $getHtmlFailure(reason)


when not defined release:
    getHtmlIndex().writeFile()
    getHtml404().writeFile()
