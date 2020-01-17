module HomePage exposing (view)

import Html.Styled as Html exposing (Html)
import Metadata exposing (Metadata, PageMetadata)
import Pages
import Pages.PagePath as PagePath exposing (PagePath)


view : List ( PagePath Pages.PathKey, Metadata ) -> PageMetadata -> Html msg -> List (Html msg)
view siteMetadata pageMetadata rendered =
    [ Html.h1 [] [ Html.text pageMetadata.title ]
    , rendered
    , Html.text "latest posts"
    ]
