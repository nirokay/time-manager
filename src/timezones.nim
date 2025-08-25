import std/[strutils, tables]
import typedefs, database

proc getUtcOffsetText*(offset: int): string =
    result = "UTC"
    if offset < 0: result.add $offset
    else: result.add "+" & $offset

proc getMinuteAlpha*(minutes: int): float =
    if minutes < 0: return 0
    result = float(minutes) / 60
    if result > 1.0: result = 1.0
proc getDayMultiplicator*(day: Days): int =
    result = case day:
        of Monday: 0
        of Tuesday: 1
        of Wednesday: 2
        of Thursday: 3
        of Friday: 4
        of Saturday: 5
        of Sunday: 6
proc getIndex*(day: Days, hour: int): int =
    let
        multiplicator: int = day.getDayMultiplicator()
        dayOffset: int = multiplicator * 24
    result = (dayOffset + hour + 24*7) mod (24*7)

proc normalizeTimes*(input: UserInput): TimeList =
    let offset: int = input.timezone
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

        if hourEnding > hourBegin:
            hourEnding += 24
        elif hourEnding == hourBegin:
            if hourBegin >= hourEnding: hourEnding += 24

        # i failed math classes, idk why it does some fuckery, anyways, this kinda fixes it:
        hourEnding -= 24*7
        while hourEnding < hourBegin: hourEnding += 24

        echo input.username, " for day ", $day
        echo "Begin  ", hourBegin
        echo "Ending ", hourEnding
        echo "Range  ", hourEnding - hourBegin
        for thisHour in hourBegin..hourEnding:
            let minutes: int = block:
                if thisHour == hourBegin and thisHour == hourEnding: minuteEnding - minuteBegin
                elif thisHour == hourBegin: 60 - minuteBegin
                elif thisHour == hourEnding: minuteEnding
                else: 60
            result[getIndex(day, thisHour)] = getMinuteAlpha(minutes)
            echo "Hour: ", thisHour, " Index: ", getIndex(day, thisHour), " Alpha: ", getMinuteAlpha(minutes)
