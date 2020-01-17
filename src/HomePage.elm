module HomePage exposing (view)

import Html.Styled as Html exposing (Html)
import Metadata exposing (Metadata, PageMetadata)
import Pages
import Pages.PagePath as PagePath exposing (PagePath)


view : List ( PagePath Pages.PathKey, Metadata ) -> PageMetadata -> List (Html msg)
view siteMetadata pageMetadata =
    [ Html.text "hey" ]
