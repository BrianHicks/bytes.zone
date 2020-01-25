module Metadata exposing (IndexCategory(..), Metadata(..), PageMetadata, decoder)

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
                            |> Decode.map (\title -> Page { title = title })

                    "homepage" ->
                        Decode.field "title" Decode.string
                            |> Decode.map (\title -> HomePage { title = title })

                    "post" ->
                        Decode.field "title" Decode.string
                            |> Decode.map (\title -> Post { title = title })

                    "code" ->
                        Decode.field "title" Decode.string
                            |> Decode.map (\title -> Code { title = title })

                    "talk" ->
                        Decode.map2
                            (\title event ->
                                Talk
                                    { title = title
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
