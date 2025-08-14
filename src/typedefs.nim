import std/[asynchttpserver, strutils, strformat, tables, json, options, re, os]
import cattag, db_connector/db_sqlite
import cssstuff
type
    ServerResponse* = object
        code*: HttpCode
        content*: string

    Days* = enum
        Monday
        Tuesday
        Wednesday
        Thursday
        Friday
        Saturday
        Sunday

    UserInput* = object
        timestamp*: int
        username*: string
        timezone*: int
        times*: OrderedTable[Days, array[2, string]]

    TimeList* = array[7 * 24, float]

    Result*[T] = object
        error*: bool
        message*: string
        result*: Option[T]

proc fail(message: string): Result[UserInput] = Result[UserInput](
    error: true,
    message: message,
    result: none UserInput
)

proc parseUserInput*(json: JsonNode): Result[UserInput] = # what a mf does for good error messages...
    if not json.fields.hasKey("username"): return fail("Field <code>username</code> does not exist.")
    if not json.fields.hasKey("timezone"): return fail("Field <code>timezone</code> does not exist.")
    if not json.fields.hasKey("times"): return fail("Field <code>times</code> does not exist.")

    let
        rawUsername: JsonNode = json.fields["username"]
        rawTimezone: JsonNode = json.fields["timezone"]
        rawTimes: JsonNode = json.fields["times"]

    if rawUsername.kind != JString: return fail("Field <code>username</code> is not of type <code>string</code>.")
    if rawTimezone.kind != JInt: return fail("Field <code>timezone</code> is not of type <code>int</code>.")
    if rawTimes.kind != JObject: return fail("Field <code>times</code> is not of type <code>object</code>.")

    let
        username: string = rawUsername.str
        timezone: int = rawTimezone.num
        timesFields: OrderedTable[string, JsonNode] = rawTimes.fields
    var userInput: UserInput = UserInput(
        username: username,
        timezone: timezone
    )

    for dayEnum in Days:
        let day: string = $dayEnum
        if not timesFields.hasKey(day): return fail(&"Missing data for day {day}.") # should not happen with normal usage

        let node: JsonNode = timesFields[day]
        if node.kind != JArray: return fail(&"Malformed data for day {day}, is not of type <code>array</code>.")

        let list: seq[JsonNode] = node.elems
        if list.len() != 2: return fail(&"Malformed data for day {day}, array has a length of {list.len()} instead of 2.")

        for index, value in list:
            if value.kind != JString: return fail(&"Index {index} in list for day {day} is not of type <code>string</code>.")

        let
            timeStart: string = list[0].str
            timeEnd: string = list[1].str
        if (timeStart == "" and timeEnd != "") or (timeStart != "" and timeEnd == ""):
            return fail(&"Malformed data for day {day}, both array values must be either set or empty <code>string</code>s!")

        for i, time in [timeStart, timeEnd]:
            if time == "": continue
            if not match(time, re"^\d?[0-2]\d?[0-9]:\d?[0-5]\d?[0-9]$"):
                return fail(&"Malformed data for day {day} in index {i}, time <code>{time}</code> does not match regex.")

        userInput.times[dayEnum] = [timeStart, timeEnd]

    return Result[UserInput](
        error: false,
        message: "",
        result: some userInput
    )

proc parseUserInput*(payload: string): Result[UserInput] =
    var json: JsonNode
    try:
        json = payload.parseJson()
    except ValueError:
        return fail("Invalid JSON, failed to parse.")
    try:
        result = json.parseUserInput()
    except CatchableError as e:
        return fail(&"Internal error: {e.name} ({e.msg})")

proc toUserInput*(row: Row): UserInput =
    ## Converts `Row` to `UserInput`
    proc toArray(str: string): array[2, string] =
        if str == "": return ["", ""]
        let parts: seq[string] = str.split(":")
        if parts.len() != 2: return ["", ""] # should not happen
        return [parts[0], parts[1]]
    proc tryParse(str: string): int =
        try: result = str.parseInt()
        except CatchableError: result = 0

    result = UserInput(
        timestamp: row[0].tryParse(),
        username: row[1],
        timezone: row[2].tryParse()
    )
    var dayCounter: int = 0
    for day in Days:
        result.times[day] = row[3 + dayCounter].toArray()
        inc dayCounter


proc newPage*(fileName, tabTitle, description: string): HtmlDocument =
    let desc: string = "TimeManager lets you submit the time-frame when you are free."
    result = newHtmlDocument(fileName)
    result.addToHead(
        title(html tabTitle),
        meta(@["property" <=> "og:title", "content" <=> tabTitle]),
        meta(@["name" <=> "description", "content" <=> desc]),
        meta(@["property" <=> "og:description", "content" <=> description]),
        meta("utf-8"),
        meta(@["content" <=> "width=device-width, initial-scale=1", "name" <=> "viewport"]),
        style(html stylesheet),
        link().add(
            "href" <=> "https://www.nirokay.com/styles.css",
            "rel" <=> "stylesheet"
        )
    )

proc embedJS*(document: var HtmlDocument, file: string) =
    let
        path: string = "docs" / "javascript" / file & ".js"
        content: string = path.readFile()
    document.addToHead(script(true, content))
