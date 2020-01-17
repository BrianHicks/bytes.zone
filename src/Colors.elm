module Colors exposing
    ( white
    , greyLightest, greyMid, greyDarkest
    , greenLightest, greenMid, greenDarkest
    )

{-|

@docs white

@docs greyLightest, greyMid, greyDarkest

@docs greenLightest, greenMid, greenDarkest

-}

import Color exposing (Color)


white : Color
white =
    Color.rgb255 248 248 249


greyLightest : Color
greyLightest =
    Color.rgb255 117 118 123


greyMid : Color
greyMid =
    Color.rgb255 53 56 63


greyDarkest : Color
greyDarkest =
    Color.rgb255 31 34 42


greenLightest : Color
greenLightest =
    Color.rgb255 120 226 160


greenMid : Color
greenMid =
    Color.rgb255 93 169 125


greenDarkest : Color
greenDarkest =
    Color.rgb255 49 72 66
