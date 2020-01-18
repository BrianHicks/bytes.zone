module HomePage exposing (view)

import Css
import Elements
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Metadata exposing (Metadata, PageMetadata)
import Pages
import Pages.PagePath as PagePath exposing (PagePath)


view : List ( PagePath Pages.PathKey, Metadata ) -> PageMetadata -> Html msg -> List (Html msg)
view siteMetadata pageMetadata rendered =
    [ Elements.h1 [] [ Html.text pageMetadata.title ]
    , Elements.p 1
        []
        [ Html.text "My name is Brian! I'm the lead organizer of "
        , Elements.a [ Attr.href "https://www.elm-conf.com" ] [ Html.text "elm-conf" ]
        , Html.text " and the author of "
        , Elements.a [ Attr.href "https://www.brianthicks.com/json-survival-kit/" ] [ Html.text "Mastering Elm: JSON Decoders" ]
        , Html.text " and a bunch of Elm packages. You've found my site!"
        ]
    , Elements.p 0 [] [ Html.text "latest posts" ]
    , Elements.p -1 [] [ Html.text "Made with Love in St. Louis, MO. Have a wonderful day! ❤️" ]
    ]
