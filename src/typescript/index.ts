const days: string[] = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
];
const idUsername: string = "id-input-username";
const idPrefixDay: string = "id-day-";
const idTimeZone: string = "id-timezone";

const idValidateSection: string = "section-validate";
const idValidateZone: string = "id-validate-zone";

function idDay(str: string): string {
    return idPrefixDay + str;
}
function idDayAvailable(str: string): string {
    return idPrefixDay + str + "-available";
}
function idDayStart(str: string): string {
    return idPrefixDay + str + "-time-start";
}
function idDayEnd(str: string): string {
    return idPrefixDay + str + "-time-end";
}

type Days = Record<string, string[]>;
function readAllDays(): Days {
    let result: Days = {};
    days.forEach((day) => {
        let idStart: string = idDayStart(day);
        let idEnd: string = idDayEnd(day);

        let elementStart: HTMLInputElement | null = document.getElementById(
            idStart,
        ) as HTMLInputElement;
        let elementEnd: HTMLInputElement | null = document.getElementById(
            idEnd,
        ) as HTMLInputElement;

        let timeStart: string = "";
        if (elementStart != null) timeStart = elementStart.value;
        let timeEnd: string = "";
        if (elementEnd != null) timeEnd = elementEnd.value;

        result[day] = [timeStart, timeEnd];
    });
    return result;
}

type UserInput = {
    username: string;
    timezone: number;
    times: Days;
};
function readAllInputs(): UserInput | null {
    let username: string = "";
    let timezone: number = 0;

    let usernameElement: HTMLInputElement | null = document.getElementById(
        idUsername,
    ) as HTMLInputElement;
    let timezoneElement: HTMLInputElement | null = document.getElementById(
        idTimeZone,
    ) as HTMLInputElement;
    if (usernameElement == null) {
        alert("Username field not found, aborting...");
        return null;
    }
    if (timezoneElement == null) {
        alert("Timezone field not found, aborting...");
        return null;
    }

    if (usernameElement.value == "") {
        alert("You have to provide an username!");
        return null;
    } else {
        username = usernameElement.value;
    }
    if (timezoneElement.value == "") {
        alert("You have to provide an UTC offset (for your timezone)!");
        return null;
    } else {
        let num: string = timezoneElement.value;
        try {
            timezone = parseInt(num);
        } catch (e) {
            console.error(e);
            alert("You have to provide a valid number for UTC offset!");
            return null;
        }
    }

    let dayTimes: Days = readAllDays();
    return {
        username: username,
        timezone: timezone,
        times: dayTimes,
    };
}
function timezoneFormat(offset: number): string {
    if (offset < 0) {
        return "UTC" + offset;
    } else {
        return "UTC+" + offset;
    }
}
function stringifyInput(data: UserInput): string {
    let result: string[] = [];
    result.push(
        "<b>Username:</b> <pre>" + data.username + "</pre>",
        "<b>Timezone:</b> <pre>" + timezoneFormat(data.timezone) + "</pre>",
    );

    days.forEach((day) => {
        let times: string[] = data.times[day];
        let line: string[] = ["<b>" + day + ":</b> "];
        let start = times[0];
        let end = times[1];
        if (start == "" && end == "") {
            line.push("<pre> / </pre>");
        } else {
            let s = start == "" ? "UNDEFINED" : start;
            let e = end == "" ? "UNDEFINED" : end;

            line.push(
                "<pre>" +
                    s +
                    " - " +
                    e +
                    " " +
                    timezoneFormat(data.timezone) +
                    "</pre>",
            );
        }
        result.push(line.join(""));
    });

    return result.join("\n");
}

function handleSubmitValidate() {
    let result: UserInput | null = readAllInputs();
    if (result == null) return;

    let validateElement: HTMLElement | null =
        document.getElementById(idValidateSection);
    if (validateElement == null) {
        alert("Validate section not found, aborting...");
        return;
    }
    validateElement.style.display = "block";

    let zoneElement: HTMLElement | null =
        document.getElementById(idValidateZone);
    if (zoneElement == null) {
        alert("Validate zone not found, aborting...");
        return;
    }
    zoneElement.innerHTML = stringifyInput(result);
}

function handleSubmitSend() {
    let result: UserInput | null = readAllInputs();
    if (result == null) return;

    let jsonRepr: string = JSON.stringify(result);
    let base64: string = btoa(jsonRepr);

    window.location.href = "submit/" + base64;
}
