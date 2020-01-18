module Main exposing (main)

import Colors
import Css
import Css.Global
import Css.Reset as Reset
import Date
import Head
import Head.Seo as Seo
import HomePage
import Html as RootHtml
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Index
import Json.Decode
import Markdown
import Metadata exposing (Metadata)
import Pages exposing (images, pages)
import Pages.Directory as Directory exposing (Directory)
import Pages.Document
import Pages.ImagePath as ImagePath exposing (ImagePath)
import Pages.Manifest as Manifest
import Pages.Manifest.Category
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Platform exposing (Page)
import Pages.StaticHttp as StaticHttp


manifest : Manifest.Config Pages.PathKey
manifest =
    { backgroundColor = Just Colors.white
    , categories =
        [ Pages.Manifest.Category.education
        , Pages.Manifest.Category.productivity
        ]
    , displayMode = Manifest.Standalone
    , orientation = Manifest.Portrait
    , description = "get in the bytes zone"
    , iarcRatingId = Nothing
    , name = "bytes.zone"
    , themeColor = Just Colors.greenMid
    , startUrl = pages.index
    , shortName = Just "bytes.zone"
    , sourceIcon = images.iconPng
    }


type alias Rendered =
    Html Msg


main : Pages.Platform.Program Model Msg Metadata Rendered
main =
    Pages.Platform.application
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , documents = [ markdownDocument ]
        , manifest = manifest
        , canonicalSiteUrl = canonicalSiteUrl
        , onPageChange = \_ -> ()
        , internals = Pages.internals
        }


markdownDocument : ( String, Pages.Document.DocumentHandler Metadata Rendered )
markdownDocument =
    Pages.Document.parser
        { extension = "md"
        , metadata = Metadata.decoder
        , body =
            \markdownBody ->
                Ok <| Html.div [] [ Html.fromUnstyled <| Markdown.toHtml [] markdownBody ]
        }


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( Model, Cmd.none )


type alias Msg =
    ()


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        () ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view :
    List ( PagePath Pages.PathKey, Metadata )
    ->
        { path : PagePath Pages.PathKey
        , frontmatter : Metadata
        }
    ->
        StaticHttp.Request
            { view : Model -> Rendered -> { title : String, body : RootHtml.Html Msg }
            , head : List (Head.Tag Pages.PathKey)
            }
view siteMetadata page =
    StaticHttp.succeed
        { view =
            \model viewForPage ->
                let
                    { title, body } =
                        pageView model siteMetadata page viewForPage
                in
                { title = title
                , body = Html.toUnstyled body
                }
        , head = head page.frontmatter
        }


pageView :
    Model
    -> List ( PagePath Pages.PathKey, Metadata )
    -> { path : PagePath Pages.PathKey, frontmatter : Metadata }
    -> Rendered
    -> { title : String, body : Html Msg }
pageView model siteMetadata page viewForPage =
    case page.frontmatter of
        Metadata.HomePage metadata ->
            { title = metadata.title
            , body = pageFrame <| HomePage.view siteMetadata metadata viewForPage
            }

        Metadata.Page metadata ->
            { title = metadata.title
            , body = pageFrame [ Html.text "TODO: PAGE!" ]
            }


pageFrame : List (Html msg) -> Html msg
pageFrame stuff =
    Html.main_
        []
        (Reset.meyerV2
            :: Reset.borderBoxV201408
            :: Css.Global.global
                [ Css.Global.body
                    [ Css.backgroundColor (Colors.toCss Colors.white)
                    , Css.fontSize (Css.px 18)
                    ]
                ]
            :: Html.node "link"
                [ Attr.href "https://fonts.googleapis.com/css?family=Exo+2:400,700|Open+Sans&display=swap"
                , Attr.rel "stylesheet"
                ]
                []
            :: pageHeader
            :: stuff
        )


pageHeader : Html msg
pageHeader =
    Html.header []
        [ Html.a [] [ Html.text "bytes.zone" ]
        , Html.a [] [ Html.text "talks" ]
        , Html.a [] [ Html.text "posts" ]
        , Html.a [] [ Html.text "code" ]
        ]


{-| <https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/abouts-cards>
<https://htmlhead.dev>
<https://html.spec.whatwg.org/multipage/semantics.html#standard-metadata-names>
<https://ogp.me/>
-}
head : Metadata -> List (Head.Tag Pages.PathKey)
head metadata =
    case metadata of
        Metadata.HomePage meta ->
            Seo.summaryLarge
                { canonicalUrlOverride = Nothing
                , siteName = "bytes.zone"
                , image =
                    { url = images.iconPng
                    , alt = "bytes.zone logo"
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = siteTagline
                , locale = Nothing
                , title = meta.title
                }
                |> Seo.website

        Metadata.Page meta ->
            Seo.summaryLarge
                { canonicalUrlOverride = Nothing
                , siteName = "bytes.zone"
                , image =
                    { url = images.iconPng
                    , alt = "bytes.zone logo"
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = siteTagline
                , locale = Nothing
                , title = meta.title
                }
                |> Seo.website


canonicalSiteUrl : String
canonicalSiteUrl =
    "https://bytes.zone/"


siteTagline : String
siteTagline =
    "get in the bytes zone"


publishedDateView metadata =
    Html.text
        (metadata.published
            |> Date.format "MMMM ddd, yyyy"
        )
