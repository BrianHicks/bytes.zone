module Elements exposing (..)

import Color
import Colors
import Css exposing (Style)
import Css.Global
import Html.Styled as Html exposing (Attribute, Html)
import Html.Styled.Attributes as Attr exposing (css)
import Markdown.Html
import Markdown.Parser exposing (Renderer)
import ModularScale
import Time


renderer : Renderer (Html msg)
renderer =
    { heading =
        \{ level, rawText, children } ->
            case level of
                1 ->
                    h1 [] children

                2 ->
                    h2 [] children

                3 ->
                    h3 [] children

                _ ->
                    Html.text "unimplemented header level"
    , raw = p 0 []
    , plain = Html.text
    , code = \_ -> Html.text "code"
    , bold = \text -> strong [] [ Html.text text ]
    , italic = \text -> em [] [ Html.text text ]
    , link = \{ title, destination } caption -> Ok (a [ Attr.href destination, Attr.title (Maybe.withDefault "" title) ] caption)
    , image = \_ _ -> Ok (Html.text "image")
    , unorderedList = \_ -> Html.text "unordered list"
    , orderedList =
        \start items ->
            ol
                { start = start
                , scale = 0
                , children = items
                , attrs = []
                }
    , codeBlock = \{ body, language } -> codeBlock language [] [ Html.text body ]
    , thematicBreak = Html.text "thematic break"
    , html =
        Markdown.Html.oneOf
            [ Markdown.Html.tag "youtube"
                (\id children -> youtube id [] children)
                |> Markdown.Html.withAttribute "id"
            ]
    }


exo2 : Css.Style
exo2 =
    Css.fontFamilies [ "\"Exo 2\"", "sans-serif" ]


openSans : Css.Style
openSans =
    Css.fontFamilies [ "\"Open Sans\"", "sans-serif" ]


jetbrainsMono : Css.Style
jetbrainsMono =
    Css.fontFamilies [ "\"Jetbrains Mono\"", "monospace" ]


h1 : List (Attribute msg) -> List (Html msg) -> Html msg
h1 =
    heading 3 Html.h1 True


h2 : List (Attribute msg) -> List (Html msg) -> Html msg
h2 =
    heading 2 Html.h2 True


h3 : List (Attribute msg) -> List (Html msg) -> Html msg
h3 =
    heading 1 Html.h3 False


heading :
    Float
    -> (List (Attribute msg) -> List (Html msg) -> Html msg)
    -> Bool
    -> List (Attribute msg)
    -> List (Html msg)
    -> Html msg
heading scale tag underline attrs children =
    tag
        (css
            [ Css.paddingLeft (ModularScale.rem 2)
            , Css.marginTop (ModularScale.rem 2)
            , Css.maxWidth (ModularScale.rem 8.5)
            , Css.position Css.relative
            , Css.fontWeight Css.bold
            , Css.color (Colors.toCss Colors.greyDarkest)
            , exo2
            , if underline then
                Css.before
                    [ Css.height (Css.pct 100)
                    , Css.width (ModularScale.rem 2)
                    , Css.position Css.absolute
                    , Css.top Css.zero
                    , Css.left Css.zero
                    , Css.property "content" "''"
                    , connectorUnderline (scale - 2)
                    ]

              else
                Css.batch []
            ]
            :: attrs
        )
        [ Html.span
            [ css
                [ if underline then
                    headerUnderline (scale - 2)

                  else
                    Css.batch []
                , Css.lineHeight (ModularScale.rem (scale + 1))
                , Css.paddingRight (ModularScale.rem 0)
                , Css.fontSize (ModularScale.rem scale)
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
            [ Css.color (Colors.toCss Colors.greyDarkest)
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
            [ Css.color (Colors.toCss Colors.greyDarkest)
            , Css.textDecoration Css.none
            , Css.property "transition" "all 0.25s"
            , Css.paddingLeft (ModularScale.rem -4)
            , Css.paddingRight (ModularScale.rem -4)
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


strong : List (Attribute msg) -> List (Html msg) -> Html msg
strong attrs children =
    Html.strong
        (css [ Css.fontWeight (Css.int 700) ] :: attrs)
        children


em : List (Attribute msg) -> List (Html msg) -> Html msg
em attrs children =
    Html.em
        (css [ Css.fontStyle Css.italic ] :: attrs)
        children


codeBlock : Maybe String -> List (Attribute msg) -> List (Html msg) -> Html msg
codeBlock language attrs children =
    Html.pre
        (css
            [ Css.fontSize (ModularScale.rem 0)
            , Css.lineHeight (ModularScale.rem 1)
            , Css.marginTop (ModularScale.rem 1)
            , Css.marginLeft (ModularScale.rem 3)
            , Css.maxWidth (Css.calc (ModularScale.rem 7.5) Css.plus (ModularScale.rem 2))
            , Css.marginRight (ModularScale.rem 2)
            , Css.color (Colors.toCss Colors.greyDarkest)
            , jetbrainsMono
            ]
            :: attrs
        )
        [ Html.code
            [ Attr.class (Maybe.withDefault "plaintext" language) ]
            children
        ]


youtube : String -> List (Attribute msg) -> List (Html msg) -> Html msg
youtube id attrs children =
    Html.figure
        (css
            [ Css.paddingLeft (ModularScale.rem 2)
            , Css.paddingRight (ModularScale.rem 2)
            , Css.maxWidth (Css.calc (ModularScale.rem 8) Css.plus (ModularScale.rem 2))
            , Css.marginTop (ModularScale.rem 2)
            ]
            :: attrs
        )
        [ Html.div
            [ css
                [ Css.position Css.relative
                , Css.paddingBottom (Css.pct 56.25)
                , Css.height Css.zero
                , Css.overflow Css.hidden
                , Css.maxWidth (Css.pct 100)
                , Css.Global.descendants
                    [ Css.Global.each
                        [ Css.Global.selector "iframe"
                        , Css.Global.selector "object"
                        , Css.Global.selector "embed"
                        ]
                        [ Css.position Css.absolute
                        , Css.top Css.zero
                        , Css.left Css.zero
                        , Css.height (Css.pct 100)
                        , Css.width (Css.pct 100)
                        ]
                    ]
                ]
            ]
            [ Html.iframe
                [ Attr.src ("https://www.youtube.com/embed/" ++ id)
                , Attr.attribute "frameBorder" "0"
                , Attr.attribute "allowfullscreen" "true"
                ]
                []
            ]
        ]


hr : Html msg
hr =
    Html.hr
        [ css
            [ Css.maxWidth (Css.calc (ModularScale.rem 7.5) Css.plus (ModularScale.rem 2))
            , Css.paddingLeft (ModularScale.rem 2)
            , Css.textAlign Css.left
            , Css.marginLeft Css.zero
            , Css.height (ModularScale.rem -2)
            , Css.backgroundColor (Colors.toCss Colors.greenLightest)
            , Css.border Css.zero
            , Css.marginTop (ModularScale.rem 5)
            ]
        ]
        []


ol :
    { scale : Float
    , start : Int
    , attrs : List (Attribute msg)
    , children : List (List (Html msg))
    }
    -> Html msg
ol { scale, start, attrs, children } =
    children
        |> List.map (Html.li [])
        |> Html.ol
            (css
                [ -- list
                  Css.listStyleType Css.decimal
                , Css.listStylePosition Css.outside
                , Css.paddingLeft (ModularScale.rem 3.5)

                -- guts
                , openSans
                , Css.fontSize (ModularScale.rem scale)
                , Css.lineHeight (ModularScale.rem (scale + 1))
                , Css.marginTop (ModularScale.rem (min 1 (scale + 1)))
                , Css.maxWidth (Css.calc (ModularScale.rem 7.5) Css.plus (ModularScale.rem 2))
                , Css.marginRight (ModularScale.rem 2)
                , Css.color (Colors.toCss Colors.greyDarkest)
                ]
                :: attrs
            )


publishedAt : Time.Posix -> Html msg
publishedAt when =
    let
        -- I live in the Midwest (-5 / -6) so I'm just going to set
        -- publication dates relative to when I mean to publish things. If
        -- things end up being off by one occasionally, that's OK.
        zone =
            Time.customZone (-6 * 60) []

        month =
            case Time.toMonth zone when of
                Time.Jan ->
                    "January"

                Time.Feb ->
                    "February"

                Time.Mar ->
                    "March"

                Time.Apr ->
                    "April"

                Time.May ->
                    "May"

                Time.Jun ->
                    "June"

                Time.Jul ->
                    "July"

                Time.Aug ->
                    "August"

                Time.Sep ->
                    "September"

                Time.Oct ->
                    "October"

                Time.Nov ->
                    "November"

                Time.Dec ->
                    "December"

        day =
            String.fromInt (Time.toDay zone when)

        year =
            String.fromInt (Time.toYear zone when)
    in
    Html.text (month ++ " " ++ day ++ ", " ++ year)
