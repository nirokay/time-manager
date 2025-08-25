import std/[strformat]
import cattag
import typedefs, database, cssstuff, timezones

proc getOpacityFor(input: UserInput, day: Days, hour: int): float =
    let
        times: TimeList = input.normalizeTimes()
        multiplicator: int = day.getDayMultiplicator()
        index: int = getIndex(day, hour)
    result = times[index]

proc getRowItemsFromInput(input: UserInput, day: Days): seq[HtmlElement] =
    # Username:
    let utcTime: string = "(" & getUtcOffsetText(input.timezone) & ")"
    result.add td(html &"{input.username} {small(i html utcTime)}")

    # Times:
    for hour in 0..23:
        let
            alpha: float = block:
                var r: float = input.getOpacityFor(day, hour)
                if r < 0: r = 0
                if r > 1: r = 1
                r
            minutes: string = block:
                let
                    f: float = alpha * 60
                    i: int = int f
                var s: string = $i
                if s.len() != 2: s = "0" & s
                if s == "00": s = ""
                s
        result.add td(html minutes).setStyle(
            backgroundColor := &"rgba(254, 104, 179, {alpha})"
        ).setClass(classTableCellWithValue.selector)

        let
            prev: float = input.getOpacityFor(day, hour - 1)
            next: float = input.getOpacityFor(day, hour + 1)

        if prev == 0 and next != 0: result[^1].setClass(classTableCellStarting.selector)
        if next == 0 and prev != 0: result[^1].setClass(classTableCellEnding.selector)

        if minutes != "":
            result[^1].setTitle(&"{minutes} minutes")


proc getResultTimeTableDay(day: Days): HtmlElement =
    result = tbody()
    var rowHeader: seq[HtmlElement] = @[th(html"Username")]
    for hour in 0..23:
        let h: string = block:
            var r: string = $hour
            if r.len() == 1: r = "0" & r
            r
        rowHeader.add th(html h).setClass(classTableHeaderRow.selector).addattr("title", &"{h}:00 - {h}:59 UTC")
        if hour == 0: rowHeader[^1].setClass(classTableCellStarting.selector)
        elif hour == 23: rowHeader[^1].setClass(classTableCellEnding.selector)
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
