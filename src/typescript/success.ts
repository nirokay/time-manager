function redirect() {
    window.location.replace("/results");
}

window.onload = function () {
    setTimeout(redirect, 2000);
};
