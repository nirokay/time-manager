import std/[asynchttpserver, strformat, tables, json, options, re]
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
        username*: string
        timezone*: int
        times*: OrderedTable[Days, array[2, string]]

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
    if not json.fields.hasKey("username"): return fail("Field <pre>username</pre> does not exist.")
    if not json.fields.hasKey("timezone"): return fail("Field <pre>timezone</pre> does not exist.")
    if not json.fields.hasKey("times"): return fail("Field <pre>times</pre> does not exist.")

    let
        rawUsername: JsonNode = json.fields["username"]
        rawTimezone: JsonNode = json.fields["timezone"]
        rawTimes: JsonNode = json.fields["times"]

    if rawUsername.kind != JString: return fail("Field <pre>username</pre> is not of type <pre>string</pre>.")
    if rawTimezone.kind != JInt: return fail("Field <pre>timezone</pre> is not of type <pre>int</pre>.")
    if rawTimes.kind != JObject: return fail("Field <pre>times</pre> is not of type <pre>object</pre>.")

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
        if node.kind != JArray: return fail(&"Malformed data for day {day}, is not of type <pre>array</pre>.")

        let list: seq[JsonNode] = node.elems
        if list.len() != 2: return fail(&"Malformed data for day {day}, array has a length of {list.len()} instead of 2.")

        for index, value in list:
            if value.kind != JString: return fail(&"Index {index} in list for day {day} is not of type <pre>string</pre>.")

        let
            timeStart: string = list[0].str
            timeEnd: string = list[1].str
        if (timeStart == "" and timeEnd != "") or (timeStart != "" and timeEnd == ""):
            return fail(&"Malformed data for day {day}, both array values must be either set or empty <pre>string</pre>s!")

        for i, time in [timeStart, timeEnd]:
            if time == "": continue
            if not match(time, re"^\d?[0-2]\d?[0-9]:\d?[0-5]\d?[0-9]$"):
                return fail(&"Malformed data for day {day} in index {i}, time <pre>{time}</pre> does not match regex.")

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
