import std/[strutils, tables]
import typedefs, database

proc getMinuteAlpha*(minutes: int): float =
    if minutes < 0: return 0
    result = float(minutes mod 60) / 60
proc getDayMultiplicator*(day: Days): int =
    var counter: int
    for d in Days:
        if d == day: return counter
        inc counter
proc getIndex*(day: Days, hour: int): int =
    let multiplicator: int = day.getDayMultiplicator()
    result = ((multiplicator * 24) + hour + 24*7) mod 24*7


proc normalizeTimes*(input: UserInput): TimeList =
    let offset: int = input.timezone
    echo input.username, ": ", input.times
    for day in Days:
        let
            times = input.times[day]
            beginning: string = times[0]
            ending: string = times[1]
        if beginning == "" and ending == "": continue

        var
            hourBegin: int
            minuteBegin: int
            hourEnding: int
            minuteEnding: int
        for i, time in [beginning, ending]:
            let
                parts: seq[string] = time.split(":")
                hour: int = parts[0].parseInt()
                minute: int = parts[1].parseInt()
            case i:
            of 0:
                hourBegin = hour
                minuteBegin = minute
            of 1:
                hourEnding = hour
                minuteEnding = minute
            else:
                raise ValueError.newException("Normalizing times did not go as planned") # should not happen

        let dayMultiplicator: int = getDayMultiplicator(day)
        hourBegin -= offset
        hourEnding -= offset

        if hourEnding > hourBegin: hourEnding += 24

        echo "Begin  ", hourBegin
        echo "Ending ", hourEnding
        for hour in hourBegin..hourEnding:
            let minutes: int = block:
                if hour == hourBegin and hour == hourEnding: minuteEnding - minuteBegin
                elif hour == hourBegin: 60 - minuteBegin
                elif hour == hourEnding: minuteEnding
                else: 60
            result[getIndex(day, hour)] = getMinuteAlpha(minutes)
