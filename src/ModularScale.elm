module ModularScale exposing (rem, scale)

import Css


rem =
    scale >> Css.rem


scale : Int -> Float
scale step =
    1.61803 ^ toFloat step
