module Feed exposing (generate)

import Metadata exposing (Metadata)
import Pages
import Pages.PagePath as PagePath exposing (PagePath)
import Rss


generate :
    { title : String
    , tagline : String
    , url : List String
    , siteUrl : String
    }
    ->
        List
            { path : PagePath Pages.PathKey
            , frontmatter : Metadata
            , body : String
            }
    ->
        { path : List String
        , content : String
        }
generate { title, tagline, siteUrl, url } pages =
    { path = url
    , content =
        Rss.generate
            { title = title
            , description = tagline
            , url = siteUrl ++ "/" ++ String.join "/" url
            , lastBuildTime = Pages.builtAt
            , generator = Just "elm-pages"
            , items = List.filterMap metadataToRssItem pages
            , siteUrl = siteUrl
            }
    }


metadataToRssItem :
    { path : PagePath Pages.PathKey
    , frontmatter : Metadata
    , body : String
    }
    -> Maybe Rss.Item
metadataToRssItem { path, frontmatter, body } =
    case frontmatter of
        Metadata.Post meta ->
            Just (pageMetadataToRssItem path meta body)

        Metadata.Page meta ->
            Just (pageMetadataToRssItem path meta body)

        Metadata.Talk meta ->
            Nothing

        Metadata.Index _ ->
            Nothing

        Metadata.HomePage _ ->
            Nothing


pageMetadataToRssItem : PagePath Pages.PathKey -> Metadata.PageMetadata -> String -> Rss.Item
pageMetadataToRssItem path { title, summary, publishedAt } body =
    { title = title
    , description = Maybe.withDefault "" summary
    , url = PagePath.toString path
    , categories = []
    , author = "Brian Hicks"
    , pubDate = Rss.DateTime publishedAt
    , content = Nothing
    }
