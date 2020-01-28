module Metadata exposing (IndexCategory(..), Metadata(..), PageMetadata, categoryTitle, decoder, title)

import Date exposing (Date)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import List.Extra
import Pages
import Pages.ImagePath as ImagePath exposing (ImagePath)


type Metadata
    = Page PageMetadata
    | HomePage PageMetadata
    | Post PostMetadata
    | Code CodeMetadata
    | Talk TalkMetadata
    | Index IndexCategory


type IndexCategory
    = Posts
    | Codes
    | Talks


type alias PageMetadata =
    { title : String }


type alias PostMetadata =
    PageMetadata


type alias CodeMetadata =
    PageMetadata


type alias TalkMetadata =
    { title : String
    , event : String
    }


decoder =
    Decode.field "type" Decode.string
        |> Decode.andThen
            (\pageType ->
                case pageType of
                    "page" ->
                        Decode.field "title" Decode.string
                            |> Decode.map (\title_ -> Page { title = title_ })

                    "homepage" ->
                        Decode.field "title" Decode.string
                            |> Decode.map (\title_ -> HomePage { title = title_ })

                    "post" ->
                        Decode.field "title" Decode.string
                            |> Decode.map (\title_ -> Post { title = title_ })

                    "code" ->
                        Decode.field "title" Decode.string
                            |> Decode.map (\title_ -> Code { title = title_ })

                    "talk" ->
                        Decode.map2
                            (\title_ event ->
                                Talk
                                    { title = title_
                                    , event = event
                                    }
                            )
                            (Decode.field "title" Decode.string)
                            (Decode.field "event" Decode.string)

                    "index" ->
                        Decode.field "category" Decode.string
                            |> Decode.andThen
                                (\category ->
                                    case category of
                                        "posts" ->
                                            Decode.succeed Posts

                                        "talks" ->
                                            Decode.succeed Talks

                                        "code" ->
                                            Decode.succeed Codes

                                        _ ->
                                            Decode.fail ("Unexpected index category " ++ category)
                                )
                            |> Decode.map Index

                    _ ->
                        Decode.fail ("Unexpected page type " ++ pageType)
            )


title : Metadata -> String
title metadata =
    case metadata of
        Talk pageMeta ->
            pageMeta.title

        Page pageMeta ->
            pageMeta.title

        Post pageMeta ->
            pageMeta.title

        Code pageMeta ->
            pageMeta.title

        HomePage pageMeta ->
            pageMeta.title

        Index category ->
            categoryTitle category


categoryTitle : IndexCategory -> String
categoryTitle category =
    case category of
        Posts ->
            "Posts"

        Talks ->
            "Talks"

        Codes ->
            "Code"
