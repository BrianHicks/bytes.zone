module Elements exposing (..)

import Color
import Colors
import Css exposing (Style)
import Html.Styled as Html exposing (Attribute, Html)
import Html.Styled.Attributes as Attr exposing (css)
import Markdown.Html
import Markdown.Parser exposing (Renderer)
import ModularScale


renderer : Renderer (Html msg)
renderer =
    { heading = \_ -> Html.text "heading"
    , raw = p 0 []
    , html =
        Markdown.Html.oneOf
            [ Markdown.Html.tag "youtube"
                (\id children -> Html.text "TODO: youtube")
                |> Markdown.Html.withAttribute "id"
            ]
    , plain = Html.text
    , code = \_ -> Html.text "code"
    , bold = \_ -> Html.text "bold"
    , italic = \_ -> Html.text "italic"
    , link = \{ title, destination } caption -> Ok (a [ Attr.href destination, Attr.title (Maybe.withDefault "" title) ] caption)
    , image = \_ _ -> Ok (Html.text "image")
    , unorderedList = \_ -> Html.text "unordered list"
    , orderedList = \_ _ -> Html.text "ordered list"
    , codeBlock = \_ -> Html.text "code block"
    , thematicBreak = Html.text "thematic break"
    }


exo2 : Css.Style
exo2 =
    Css.fontFamilies [ "\"Exo 2\"", "sans-serif" ]


openSans : Css.Style
openSans =
    Css.fontFamilies [ "\"Open Sans\"", "sans-serif" ]


h1 : List (Attribute msg) -> List (Html msg) -> Html msg
h1 attrs children =
    Html.h1
        (css
            [ Css.paddingLeft (ModularScale.rem 2)
            , Css.marginTop (ModularScale.rem 2)
            , Css.maxWidth (ModularScale.rem 9)
            , Css.position Css.relative
            , Css.fontWeight Css.bold
            , Css.color (Colors.toCss Colors.greyDarkest)
            , exo2
            , Css.before
                [ Css.height (Css.pct 100)
                , Css.width (ModularScale.rem 2)
                , Css.position Css.absolute
                , Css.top Css.zero
                , Css.left Css.zero
                , Css.property "content" "''"
                , connectorUnderline 1
                ]
            ]
            :: attrs
        )
        [ Html.span
            [ css
                [ headerUnderline 1
                , Css.lineHeight (ModularScale.rem 4)
                , Css.paddingRight (ModularScale.rem 0)
                , Css.fontSize (ModularScale.rem 3)
                ]
            ]
            children
        ]


pageTitle : List (Attribute msg) -> List (Html msg) -> Html msg
pageTitle attrs children =
    Html.a
        (css
            [ exo2
            , Css.fontSize (ModularScale.rem 0)
            , Css.paddingLeft (ModularScale.rem 2)
            , Css.paddingRight (ModularScale.rem -2)
            , Css.fontWeight Css.bold
            , Css.display Css.inlineBlock
            , headerUnderline -2
            , Css.borderBottom3 (ModularScale.rem -3) Css.solid (Colors.toCss Colors.greenLightest)
            , Css.textDecoration Css.none
            , Css.color (Colors.toCss Colors.greyDarkest)
            ]
            :: attrs
        )
        children


headerUnderline : Float -> Style
headerUnderline scale =
    -- TODO: should scale be text scale or desired underline scale?
    Css.backgroundImage <|
        Css.linearGradient2
            Css.toTop
            (Css.stop (Colors.toCss Colors.greenLightest))
            (Css.stop2 (Colors.toCss Colors.greenLightest) (ModularScale.rem scale))
            [ Css.stop2 (Css.rgba 255 255 255 0) (ModularScale.rem scale) ]


connectorUnderline : Float -> Style
connectorUnderline scale =
    -- TODO: should scale be text scale or desired underline scale?
    let
        stops =
            [ "rgba(255,255,255,0)"
            , "rgba(255,255,255,0) calc(" ++ String.fromFloat (ModularScale.scale (scale - 1)) ++ "rem - 2px)"
            , Color.toCssString Colors.greenLightest ++ " calc(" ++ String.fromFloat (ModularScale.scale (scale - 1)) ++ "rem - 2px)"
            , Color.toCssString Colors.greenLightest ++ " calc(" ++ String.fromFloat (ModularScale.scale (scale - 1) + ModularScale.scale scale) ++ "rem - 2px)"
            , "rgba(255,255,255,0) calc(" ++ String.fromFloat (ModularScale.scale (scale - 1) + ModularScale.scale scale) ++ "rem - 2px)"
            , "rgba(255,255,255,0) calc(" ++ String.fromFloat (ModularScale.scale (scale + 3)) ++ "rem - 0.5px)"
            ]
    in
    Css.property "background-image" ("repeating-linear-gradient(to top," ++ String.join "," stops ++ ")")


p : Float -> List (Attribute msg) -> List (Html msg) -> Html msg
p scale attrs children =
    Html.p
        (css
            [ openSans
            , Css.fontSize (ModularScale.rem scale)
            , Css.lineHeight (ModularScale.rem (scale + 1))
            , Css.marginTop (ModularScale.rem (min 1 (scale + 1)))
            , Css.marginLeft (ModularScale.rem 2)
            , Css.maxWidth (Css.calc (ModularScale.rem 7.5) Css.plus (ModularScale.rem 2))
            , Css.marginRight (ModularScale.rem 2)
            , Css.color (Colors.toCss Colors.greyDarkest)
            ]
            :: attrs
        )
        children


a : List (Attribute msg) -> List (Html msg) -> Html msg
a attrs children =
    let
        underline =
            Css.backgroundImage
                (Css.linearGradient2
                    Css.toTop
                    (Css.stop (Colors.toCss Colors.greenLightest))
                    (Css.stop2 (Colors.toCss Colors.greenLightest) (Css.pct 35))
                    [ Css.stop2 (Css.rgba 255 255 255 0) (Css.pct 35) ]
                )
    in
    Html.a
        (css
            [ openSans
            , Css.color (Colors.toCss Colors.greyDarkest)
            , Css.textDecoration Css.none
            , Css.property "transition" "all 0.25s"
            , underline
            , Css.hover [ Css.backgroundColor (Colors.toCss Colors.greenLightest) ]
            , Css.position Css.relative
            , Css.paddingRight (ModularScale.rem -4)
            , Css.paddingLeft (ModularScale.rem -4)
            ]
            :: attrs
        )
        children


inactiveHeaderLink : List (Attribute msg) -> List (Html msg) -> Html msg
inactiveHeaderLink attrs children =
    Html.a
        (css
            [ exo2
            , Css.color (Colors.toCss Colors.greyDarkest)
            , Css.textDecoration Css.none
            , Css.property "transition" "all 0.25s"
            , Css.paddingLeft (ModularScale.rem -3)
            , Css.paddingRight (ModularScale.rem -3)
            , Css.hover
                [ Css.backgroundColor (Colors.toCss Colors.greenLightest)
                , Css.before [ Css.backgroundColor (Colors.toCss Colors.greenLightest) ]
                , Css.after [ Css.backgroundColor (Colors.toCss Colors.greenLightest) ]
                ]
            , Css.position Css.relative
            ]
            :: attrs
        )
        children
