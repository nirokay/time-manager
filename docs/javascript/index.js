"use strict";
const days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
];
const idUsername = "id-input-username";
const idPrefixDay = "id-day-";
const idTimeZone = "id-timezone";
const idValidateSection = "section-validate";
const idValidateZone = "id-validate-zone";
function idDayStart(str) {
    return idPrefixDay + str + "-time-start";
}
function idDayEnd(str) {
    return idPrefixDay + str + "-time-end";
}
function readAllDays() {
    let result = {};
    days.forEach((day) => {
        let idStart = idDayStart(day);
        let idEnd = idDayEnd(day);
        let elementStart = document.getElementById(idStart);
        let elementEnd = document.getElementById(idEnd);
        let timeStart = "";
        if (elementStart != null)
            timeStart = elementStart.value;
        let timeEnd = "";
        if (elementEnd != null)
            timeEnd = elementEnd.value;
        result[day] = [timeStart, timeEnd];
    });
    return result;
}
function readAllInputs() {
    let username = "";
    let timezone = 0;
    let usernameElement = document.getElementById(idUsername);
    let timezoneElement = document.getElementById(idTimeZone);
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
    }
    else {
        username = usernameElement.value;
    }
    if (timezoneElement.value == "") {
        alert("You have to provide an UTC offset (for your timezone)!");
        return null;
    }
    else {
        let num = timezoneElement.value;
        try {
            timezone = parseInt(num);
        }
        catch (e) {
            console.error(e);
            alert("You have to provide a valid number for UTC offset!");
            return null;
        }
    }
    let dayTimes = readAllDays();
    return {
        username: username,
        timezone: timezone,
        times: dayTimes,
    };
}
function timezoneFormat(offset) {
    if (offset < 0) {
        return "UTC" + offset;
    }
    else {
        return "UTC+" + offset;
    }
}
function stringifyInput(data) {
    let result = [];
    result.push("<u>Username:</u> <code>" + data.username + "</code><br />", "<u>Timezone:</u> <code>" +
        timezoneFormat(data.timezone) +
        "</code><br/>");
    days.forEach((day) => {
        let times = data.times[day];
        let line = ["<u>" + day + ":</u> "];
        let start = times[0];
        let end = times[1];
        if (start == "" && end == "") {
            line.push("<code> / </code><br />");
        }
        else {
            let spanUndefined = "<span style='color:red;'>UNDEFINED</span>";
            let s = start == "" ? spanUndefined : start;
            let e = end == "" ? spanUndefined : end;
            line.push("<code>" +
                s +
                " - " +
                e +
                " " +
                timezoneFormat(data.timezone) +
                "</code>" +
                "<br />");
        }
        result.push(line.join(""));
    });
    return result.join("\n");
}
function handleSubmitValidate() {
    let result = readAllInputs();
    if (result == null)
        return;
    let validateElement = document.getElementById(idValidateSection);
    if (validateElement == null) {
        alert("Validate section not found, aborting...");
        return;
    }
    validateElement.style.display = "block";
    let zoneElement = document.getElementById(idValidateZone);
    if (zoneElement == null) {
        alert("Validate zone not found, aborting...");
        return;
    }
    zoneElement.innerHTML = stringifyInput(result);
}
function handleSubmitSend() {
    let result = readAllInputs();
    if (result == null)
        return;
    let jsonRepr = JSON.stringify(result);
    let encoded = encodeURI(jsonRepr);
    let base64 = btoa(encoded);
    window.location.href = "submit/" + base64;
}
