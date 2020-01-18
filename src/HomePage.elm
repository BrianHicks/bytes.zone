module HomePage exposing (view)

import Css
import Elements
import Html.Styled as Html exposing (Html)
import Metadata exposing (Metadata, PageMetadata)
import Pages
import Pages.PagePath as PagePath exposing (PagePath)


view : List ( PagePath Pages.PathKey, Metadata ) -> PageMetadata -> Html msg -> List (Html msg)
view siteMetadata pageMetadata rendered =
    [ Elements.h1 [] [ Html.text pageMetadata.title ]
    , rendered
    , Elements.p 0 [] [ Html.text "latest posts" ]
    , Elements.p -1 [] [ Html.text "Made with Love in St. Louis, MO. Have a wonderful day! ❤️" ]
    ]
