module Index exposing (view)

import Css
import Date
import Elements
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attributes exposing (css, href)
import Metadata exposing (Metadata)
import ModularScale
import Pages
import Pages.Directory as Directory
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Platform exposing (Page)
import Time


view :
    List ( PagePath Pages.PathKey, Metadata )
    -> Metadata.IndexCategory
    -> Html msg
view allPages category =
    let
        directory =
            case category of
                Metadata.Posts ->
                    Pages.pages.posts.directory

                Metadata.Talks ->
                    Pages.pages.talks.directory

        pages =
            allPages
                |> List.filter
                    (\( path, _ ) -> path /= Directory.indexPath directory && Directory.includes directory path)
                |> List.sortBy
                    (\( _, pageMeta ) -> Time.posixToMillis (Metadata.publishedAt pageMeta) * -1)
    in
    Html.div []
        [ Elements.h1 [] [ Html.text (Metadata.categoryTitle category) ]
        , pages
            |> List.map
                (\( path, page ) ->
                    Elements.div 0
                        []
                        [ Html.h2
                            [ css
                                [ Css.fontSize (ModularScale.rem 0.5)
                                , Elements.exo2
                                ]
                            ]
                            [ Elements.a
                                [ href (PagePath.toString path)
                                , css [ Css.fontWeight Css.bold ]
                                ]
                                [ Html.text (Metadata.title page)
                                ]
                            , case page of
                                Metadata.Talk { event } ->
                                    Html.text (" at " ++ event)

                                _ ->
                                    Html.text ""
                            ]
                        , Html.text "published "
                        , Elements.publishedAt (Metadata.publishedAt page)
                        ]
                )
            |> Html.div []
        ]
