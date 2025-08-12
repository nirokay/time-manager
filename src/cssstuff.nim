import std/[strformat]
import cattag

const idValidateSection*: string = "section-validate"

const
    # Variables:
    colBackgroundDark*: string = "#171921"
    colBackgroundMiddle*: string = "#23252C"
    colBackgroundLight*: string = "#2F3139"

    colForegroundLight*: string = "#E8E6E3"

    # Locally used:
    propRounded: CssElementProperty = borderRadius := 20'px
    dropShadow*: CssElementProperty = block:
        const
            offX: int = 5
            offY: int = 5
            diffusion: int = 5
            colShadow: string = "rgba(0, 0, 0, 0.5)"
            colHighlight: string = "rgba(0, 0, 0, 0.2)"
        filter := cssDropShadow &"-{offX / 2}px -{offY / 2}px {diffusion / 2}px {colHighlight}) drop-shadow({offX}px {offY}px {diffusion}px {colShadow}"

    # Classes:
    classDayDiv*: CssElement = newCssClass("day-div",
        dropShadow,
        propRounded,
        backgroundColor := colBackgroundMiddle,
        margin := 20'px,
        padding := 10'px
    )

proc getStyles(): CssStylesheet =
    result = newCssStylesheet("styles.css")
    result.add(
        "html"{
            backgroundColor := colBackgroundDark,
            color := colForegroundLight,
            fontFamily := "Verdana, Geneva, Tahoma, sans-serif",
            fontSize := 1.2'em
        },
        "details"{
            margin := 20'px
        },
        "summary"{
            fontSize := 1.2'em,
            fontWeight := "bold"
        },
        "input"{
            dropShadow,
            propRounded,
            borderStyle := CssLineStyle.none,
            backgroundColor := colBackgroundLight,
            color := colForegroundLight,
            padding := 5'px,
            margin := 10'px
        },
        "button"{
            dropShadow,
            propRounded,
            borderStyle := CssLineStyle.none,
            backgroundColor := colBackgroundLight,
            color := colForegroundLight,
            padding := 5'px,
            margin := 10'px
        },
        "button:hover"{
            backgroundColor := colBackgroundMiddle,
            textDecoration := "underline"
        },

        newCssId(idValidateSection,
            display := CssDisplayBox.none
        ),

        classDayDiv
    )

const stylesheet*: string = $getStyles()
