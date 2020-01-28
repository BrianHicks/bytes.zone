module HomePage exposing (view)

import Css
import Elements
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Metadata exposing (HomePageMetadata, Metadata)
import Pages
import Pages.PagePath as PagePath exposing (PagePath)
import Time


view : List ( PagePath Pages.PathKey, Metadata ) -> HomePageMetadata -> Html msg -> List (Html msg)
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
    , let
        { post, code, talk } =
            siteMetadata
                |> List.sortBy (\( _, page ) -> Time.posixToMillis (Metadata.publishedAt page))
                |> List.foldl
                    (\( link, page ) latest ->
                        case page of
                            Metadata.Post meta ->
                                { latest | post = Just ( link, meta ) }

                            Metadata.Code meta ->
                                { latest | code = Just ( link, meta ) }

                            Metadata.Talk meta ->
                                { latest | talk = Just ( link, meta ) }

                            _ ->
                                latest
                    )
                    { post = Nothing
                    , code = Nothing
                    , talk = Nothing
                    }

        phrases =
            List.filterMap identity
                [ Maybe.map
                    (\( path, { title } ) ->
                        Html.span []
                            [ Html.text "The latest post I wrote was "
                            , Elements.a [ Attr.href (PagePath.toString path) ] [ Html.text title ]
                            , Html.text ", "
                            ]
                    )
                    post
                , Maybe.map
                    (\( path, { title } ) ->
                        Html.span []
                            [ Html.text "the latest code I released was "
                            , Elements.a [ Attr.href (PagePath.toString path) ] [ Html.text title ]
                            , Html.text ", "
                            ]
                    )
                    code
                , Maybe.map
                    (\( path, { title, event } ) ->
                        Html.span []
                            [ Html.text "and the latest talk I gave was "
                            , Elements.a [ Attr.href (PagePath.toString path) ] [ Html.text title ]
                            , Html.text " at "
                            , Html.text event
                            , Html.text "."
                            ]
                    )
                    talk
                ]
      in
      Elements.p 0 [] phrases
    , Elements.p -1 [] [ Html.text "Made with Love in St. Louis, MO. Have a wonderful day! ❤️" ]
    ]
