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

                Metadata.Codes ->
                    Pages.pages.code.directory

        pages =
            allPages
                |> List.filter
                    (\( path, _ ) -> path /= Directory.indexPath directory && Directory.includes directory path)
                |> List.sortBy
                    (\( _, pageMeta ) -> Metadata.title pageMeta)
    in
    Html.div []
        [ Elements.h1 [] [ Html.text (Metadata.categoryTitle category) ]
        , pages
            |> List.map
                (\( path, page ) ->
                    Elements.p 0
                        []
                        [ Elements.a
                            [ href (PagePath.toString path)
                            , css
                                [ Css.fontSize (ModularScale.rem 0.5)
                                , Css.fontWeight Css.bold
                                , Elements.exo2
                                ]
                            ]
                            [ Html.text (Metadata.title page)
                            ]
                        , Html.br [] []
                        , Html.text "published "
                        , Html.text "Smarch Five, Seventeen Eighty Two"
                        ]
                )
            |> Html.div []
        ]
