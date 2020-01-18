module ModularScale exposing (baseFontSize, px, rem, scale, scalePx)

import Css


baseFontSize : Int
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
        |> (*) (toFloat baseFontSize)
        |> ceiling
        |> toFloat
