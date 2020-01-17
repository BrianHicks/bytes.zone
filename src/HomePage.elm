module HomePage exposing (view)

import Colors
import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes exposing (css)
import Metadata exposing (Metadata, PageMetadata)
import ModularScale
import Pages
import Pages.PagePath as PagePath exposing (PagePath)


view : List ( PagePath Pages.PathKey, Metadata ) -> PageMetadata -> Html msg -> List (Html msg)
view siteMetadata pageMetadata rendered =
    [ Html.h1
        [ css
            [ Css.fontSize (ModularScale.rem 3)
            , Css.lineHeight (ModularScale.rem 4)
            , Css.display Css.inlineBlock
            , Css.paddingRight (ModularScale.rem 0)
            , Css.paddingLeft (ModularScale.rem 2)
            , Css.fontFamilies [ "'Exo 2'", "Helvetica", "sans-serif" ]
            , Css.backgroundImage
                (Css.linearGradient2
                    Css.toTop
                    (Css.stop (Css.rgba 255 255 255 0))
                    (Css.stop2 (Css.rgba 255 255 255 0) (ModularScale.rem 0))
                    [ Css.stop2 (Colors.toCss Colors.greenLightest) (ModularScale.rem 0)
                    , Css.stop2 (Colors.toCss Colors.greenLightest) (Css.rem (ModularScale.scale 0 + ModularScale.scale 1))
                    , Css.stop2 (Css.rgba 255 255 255 0) (Css.rem (ModularScale.scale 0 + ModularScale.scale 1))
                    ]
                )
            ]
        ]
        [ Html.text pageMetadata.title ]
    , rendered
    , Html.text "latest posts"
    ]
