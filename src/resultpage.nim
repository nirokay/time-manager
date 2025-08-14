import std/[]
import cattag
import typedefs, database, cssstuff

proc getRowItemsFromInput(input: UserInput, day: Days): seq[HtmlElement] =
    result.add td(html input.username)
    for hour in 0..23:
        result.add td()


proc getResultTimeTableDay(day: Days): HtmlElement =
    result = tbody()
    var rowHeader: seq[HtmlElement] = @[th(html"Username")]
    for hour in 0..23:
        let h: string = block:
            var r: string = $hour
            if r.len() == 1: r = "0" & r
            r
        rowHeader.add th(html h).setClass(classTableHeaderRow.selector)
    result.add tr(rowHeader)

    for input in getSubmissionListFromDatabase():
        result.add tr(getRowItemsFromInput(input, day))

    result = section(
        h3(html $day),
        table(result).setStyle(@[width := 100'percent])
    )
proc getResultTimeTable*(): seq[HtmlElement] =
    for day in Days:
        result.add getResultTimeTableDay(day)

proc getHtmlResults(): HtmlDocument =
    result = newPage("results.html", "Results - TimeManager", "See results for user submissions.")
    result.add(
        h1(html"Results"),
        p(
            html"All users submissions are visualized and split by day."
        )
    )
    result.add getResultTimeTable()
proc htmlPageResults*(): string = $getHtmlResults()
