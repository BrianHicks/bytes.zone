module ModularScale exposing (baseFontSize, px, rem, scale, scalePx)

import Css


baseFontSize : Float
baseFontSize =
    18


rem =
    scale >> Css.rem


px =
    scalePx >> Css.px


scale : Int -> Float
scale step =
    1.61803 ^ toFloat step


scalePx : Int -> Float
scalePx step =
    scale step
        |> (*) baseFontSize
        |> ceiling
        |> toFloat
