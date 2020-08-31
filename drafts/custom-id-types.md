---
{
  "type": "post",
  "title": "Reusable ID Types with Phantom Typing",
  "summary": "A nice middle ground between custom IDs everywhere and using Ints or whatever.",
  "published": "2020-08-31T00:00:00-05:00",
}
---

In Elm, we usually define a record for a remote resource like this:

```elm
module Cat exposing (Cat)


type alias Cat =
    { id : String
    , name : String
    , purriness : Int
    }
```

This has a problem, though: you can do *whatever* with that ID string.
Concatenate them? Yup.
Regex match? Why not?

But most importantly to me, this doesn't give you any assurance at the compiler level that the thing you're using (a `String`) is actually an identifier for a `Cat`.
That means that you can switch `id` and `name` and the compiler will say it's all good.
Primitive obsession strikes again!

The usual way to deal with this is to wrap in a custom opaque ID type (note how we're not exposing constructors here):

```elm
module Cat exposing (CatId, Cat)


type CatId
    = CatId String


type alias Cat =
    { id : CatId
    , name : String
    , purriness : Int
    }
```

Then to get around the `comparable` requirement for dictionaries you use a special package (there are many, but I like `rtfeldman/elm-sorter-experiment`):

```elm
idSorter : Sorter CatId
idSorter =
    Sort.by (\(CatId id) -> id) Sort.alphabetical
```

Now you can store them again, but the compiler will complain if you use a `CatId` where you need a `DogId`.
For example, you can now define a helper that builds a path for HTTP requests while disallowing invalid IDs:

```elm
apiRoute : CatId -> String
apiRoute (CatId id) =
    Url.Builder.absolute [ "api", "cats", id ] []
```

So far so good, right?
But this pattern has a big downside: you need to define `FooId`, `idSorter`, and probably `idDecoder` for every single resource type in your application.
Most of these definitions will be super similar.

While I'm not against boilerplate as a whole (in fact, yay for being explicit!) this particular usage really annoys me.
It adds friction to working with remote resources, especially if you don't define all the "normal" functions everywhere.
This tend to lead to scattered refactorings and hanger-on functions in the middle of refactorings.

But recently I was building a little app for my son to learn his letters and decided to see if I could find a nicer way in a constrained single-developer environment.
My goal was to find something in between the wild wild west of using primitives directly and the boilerplate-y repetition of defining ID types for every resource.

And, I think I did!
The key was to use phantom types (that is, types with a variable that appears in the definition but not any of the constructors.)
Let's see how it works:

```elm
module Id exposing (Id(..), decoder, sorter)

import Json.Decode as Decode exposing (Decoder)
import Sort exposing (Sorter)


type Id thing =
    Id String


decoder : Decoder (Id thing)
decoder =
    Decode.map Id Decode.string


sorter : Sorter (Id thing)
sorter =
    Sort.by (\(Id id) -> id) Sort.alphabetical
```

You use it in external definitions like this:

```elm
module Shelter exposing (Shelter)

import Cat exposing (Cat)
import Id exposing (Id)
import Json.Decode exposing (Decoder)


type alias Shelter =
    { name : String
    , adoptableCats : List (Id Cat)
    }


decoder : Decoder Shelter
decoder =
    Decode.map2 Shelter
        (Decode.field "name" Decode.string)
        (Decode.field "adoptableCats" (Decode.list Id.decoder))
```

BUT there's a tradeoff here: you can't embed the ID of a record in the record (doing so would be a recursive definition.)
This doesn't matter for my use case (all IDs are external or in routes where I can correlate them with records easily) but if you need it, it's not bad to work around while still getting the reusable decoder/sorter:

```elm
module Cat exposing (Id, Cat, decoder)

import Id exposing (Id(..))
import Json.Decode exposing (Decoder)


{-| An module-internal identifier. Has to be a custom type instead of an
alias so the compiler can detect if it's being used improperly.
-}
type CatId
    = CatId


type alias Id =
    Id CatId


type alias Cat =
    { id : Id
    , name : String
    , purriness : Int
    }


decoder : Decoder Cat
decoder =
    Decode.map3 Cat
        (Decode.field "id" Id.decoder)
        (Decode.field "name" Decode.string)
        (Decode.field "purriness" Decode.int)


apiRoute : Id -> String
apiRoute (Id id) =
    Url.Builder.absolute [ "api", "cats", id ] []
```

And there you have it!
With this technique, you get:

- nice type-checking and good errors (with really obvious fixes, like "you have a `Id Dog` but you need an `Id Cat`.")
- reasonable reuse with global-ish

But with these tradeoffs:

- You have to be disciplined about not deconstructing/matching against IDs in places where it wouldn't make sense to take responsibility for constructing them.
- To get IDs in records (as opposed to just in `Dict`s or whatever) you have to do a (small) type trick.
