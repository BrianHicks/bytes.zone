module Index exposing (title, view)

import Date
import Html.Styled as Html exposing (Html)
import Metadata exposing (Metadata)
import Pages
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Platform exposing (Page)


view : Metadata.IndexCategory -> Html msg
view category =
    Html.text "TODO: index"


title : Metadata.IndexCategory -> String
title category =
    case category of
        Metadata.Posts ->
            "Post Index"

        Metadata.Talks ->
            "Talk Index"

        Metadata.Codes ->
            "Code Index"
