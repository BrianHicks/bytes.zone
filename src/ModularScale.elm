module ModularScale exposing (baseFontSize, px, rem, scale, scalePx)

import Css


baseFontSize : Float
baseFontSize =
    18


rem =
    scale >> Css.rem


px =
    scalePx >> Css.px


scale : Float -> Float
scale step =
    1.61803 ^ step


scalePx : Float -> Float
scalePx step =
    scale step
        |> (*) baseFontSize
        |> ceiling
        |> toFloat
