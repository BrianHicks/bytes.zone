module Index exposing (view)

import Date
import Html.Styled as Html exposing (Html)
import Metadata exposing (Metadata)
import Pages
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Platform exposing (Page)


view :
    List ( PagePath Pages.PathKey, Metadata )
    -> Html msg
view posts =
    Html.text (Debug.toString posts)
