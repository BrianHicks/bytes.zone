module Metadata exposing (Metadata(..), PageMetadata, decoder)

import Date exposing (Date)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import List.Extra
import Pages
import Pages.ImagePath as ImagePath exposing (ImagePath)


type Metadata
    = Page PageMetadata
    | HomePage PageMetadata


type alias PageMetadata =
    { title : String }


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
                            |> Decode.map (\title -> Page { title = title })

                    _ ->
                        Decode.fail ("Unexpected page type " ++ pageType)
            )
