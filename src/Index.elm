module Index exposing (title, view)

import Date
import Elements
import Html.Styled as Html exposing (Html)
import Metadata exposing (Metadata)
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
                    (\( _, pageMeta ) ->
                        case pageMeta of
                            Metadata.Talk meta ->
                                meta.title

                            Metadata.Page meta ->
                                meta.title

                            Metadata.Post meta ->
                                meta.title

                            Metadata.Code meta ->
                                meta.title

                            Metadata.HomePage _ ->
                                ""

                            Metadata.Index _ ->
                                ""
                    )
    in
    Html.div []
        [ Elements.h1 [] [ Html.text (title category) ]
        , pages
            |> List.map (\( path, page ) -> Html.text (Debug.toString path))
            |> Html.ul []
        ]


title : Metadata.IndexCategory -> String
title category =
    case category of
        Metadata.Posts ->
            "Posts"

        Metadata.Talks ->
            "Talks"

        Metadata.Codes ->
            "Code"
