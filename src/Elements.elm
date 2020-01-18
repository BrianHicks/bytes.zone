module Elements exposing (..)

import Color
import Colors
import Css
import Html.Styled as Html exposing (Attribute, Html)
import Html.Styled.Attributes exposing (css)
import ModularScale


exo2 : Css.Style
exo2 =
    Css.fontFamilies [ "\"Exo 2\"", "Helvetica", "sans-serif" ]


h1 : List (Attribute msg) -> List (Html msg) -> Html msg
h1 attrs children =
    Html.h1
        (css
            [ Css.paddingLeft (ModularScale.rem 2)
            , Css.maxWidth (ModularScale.rem 9)
            , Css.position Css.relative
            , exo2
            , Css.before
                [ Css.height (Css.pct 100)
                , Css.width (ModularScale.rem 2)
                , Css.position Css.absolute
                , Css.top Css.zero
                , Css.left Css.zero
                , Css.property "content" "''"
                , let
                    stops =
                        [ "rgba(255,255,255,0)"
                        , "rgba(255,255,255,0) calc(" ++ String.fromFloat (ModularScale.scale 0) ++ "rem - 2px)"
                        , Color.toCssString Colors.greenLightest ++ " calc(" ++ String.fromFloat (ModularScale.scale 0) ++ "rem - 2px)"
                        , Color.toCssString Colors.greenLightest ++ " calc(" ++ String.fromFloat (ModularScale.scale 0 + ModularScale.scale 1) ++ "rem - 2px)"
                        , "rgba(255,255,255,0) calc(" ++ String.fromFloat (ModularScale.scale 0 + ModularScale.scale 1) ++ "rem - 2px)"
                        , "rgba(255,255,255,0) calc(" ++ String.fromFloat (ModularScale.scale 4) ++ "rem - 0.5px)"
                        ]
                  in
                  Css.property "background-image" ("repeating-linear-gradient(to top," ++ String.join "," stops ++ ")")
                ]
            ]
            :: attrs
        )
        [ Html.span
            [ css
                [ Css.backgroundImage
                    (Css.linearGradient2
                        Css.toTop
                        (Css.stop (Colors.toCss Colors.greenLightest))
                        (Css.stop2 (Colors.toCss Colors.greenLightest) (ModularScale.rem 1))
                        [ Css.stop2 (Css.rgba 255 255 255 0) (ModularScale.rem 1) ]
                    )
                , Css.lineHeight (ModularScale.rem 4)
                , Css.paddingRight (ModularScale.rem 0)
                , Css.fontSize (ModularScale.rem 3)
                ]
            ]
            children
        ]


p : Int -> List (Attribute msg) -> List (Html msg) -> Html msg
p scale attrs children =
    Html.p
        (css
            [ exo2
            , Css.fontSize (ModularScale.rem scale)
            , Css.lineHeight (ModularScale.rem (scale + 1))
            , Css.marginTop (ModularScale.rem (scale + 1))
            , Css.marginLeft (ModularScale.rem 2)
            , Css.maxWidth (ModularScale.rem 9)
            ]
            :: attrs
        )
        children
