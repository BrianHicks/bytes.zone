module Elements exposing (..)

import Colors
import Css
import Html.Styled as Html exposing (Attribute, Html)
import Html.Styled.Attributes exposing (css)
import ModularScale


h1 : List (Attribute msg) -> List (Html msg) -> Html msg
h1 attrs children =
    Html.h1
        (css
            [ Css.fontSize (ModularScale.rem 3)
            , Css.lineHeight (ModularScale.rem 4)
            , Css.display Css.inlineBlock
            , Css.paddingRight (ModularScale.rem 0)
            , Css.paddingLeft (ModularScale.rem 2)
            , Css.fontFamilies [ "\"Exo 2\"", "Helvetica", "sans-serif" ]
            , Css.backgroundImage
                (Css.linearGradient2
                    Css.toTop
                    (Css.stop (Css.rgba 255 255 255 0))
                    (Css.stop2 (Css.rgba 255 255 255 0) (ModularScale.rem 0))
                    [ Css.stop2 (Colors.toCss Colors.greenLightest) (ModularScale.rem 0)
                    , Css.stop2 (Colors.toCss Colors.greenLightest) (Css.rem (ModularScale.scale 0 + ModularScale.scale 1))
                    , Css.stop2 (Css.rgba 255 255 255 0) (Css.rem (ModularScale.scale 0 + ModularScale.scale 1))
                    ]
                )
            ]
            :: attrs
        )
        children


p : Int -> List (Attribute msg) -> List (Html msg) -> Html msg
p scale attrs children =
    Html.p
        (css
            [ Css.fontFamilies [ "'Exo 2'", "Helvetica", "sans-serif" ]
            , Css.fontSize (ModularScale.rem scale)
            , Css.lineHeight (ModularScale.rem (scale + 1))
            , Css.marginTop (ModularScale.rem (scale + 1))
            , Css.marginLeft (ModularScale.rem 2)
            ]
            :: attrs
        )
        children
