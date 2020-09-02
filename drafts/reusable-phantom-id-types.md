---
{
  "type": "post",
  "title": "Reusable Phantom ID Types",
  "summary": "A nice middle ground between custom IDs everywhere and using Ints or whatever.",
  "published": "2020-08-31T00:00:00-05:00",
}
---

In Elm, we often define modules for records like this:

```elm
module Cat exposing (Cat)

import Json.Decode as Decode exposing (Decoder)


type alias Cat =
    { id : String
    , name : String
    , purriness : Int
    }


decoder : Decoder Cat
decoder =
    Decode.map3 Cat
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "purriness" Decode.int)
```

We might construct instances of `Cat` by hand (say for some view state) but more often we load them from a server (which is why we have `decoder` there too.)

But regardless, this has a problem: you can do *whatever* with that ID string.
Concatenate it with another one?
Yup.
Regex match?
Why not!
Using a `String` here means that the compiler can't tell you if you're using the `id` in the way it was intended to be used.

## The First Pass Fix

So we have a problem, but we can fix it.
When facing this in Elm, we can make a custom opaque ID type (note the hidden constructor):

```elm
module Cat exposing (CatId, Cat)


type CatId
    = CatId String


type alias Cat =
    { id : CatId
    , name : String
    , purriness : Int
    }


decoder : Decoder Cat
decoder =
    Decode.map3 Cat
        (Decode.field "id" (Decode.map CatId Decode.string))
        (Decode.field "name" Decode.string)
        (Decode.field "purriness" Decode.int)
```

Now we cannot do arbitrary `String` operations on IDs, and we can specify IDs in signatures as well.
For example, we could define the route to get a `Cat` in our API:

```elm
apiRoute : CatId -> String
apiRoute (CatId id) =
    Url.Builder.absolute [ "api", "cats", id ] []
```

Passing anything other than a `CatId` to this function will cause a friendly compiler error along the lines of "You gave me a `String`, but I need a `CatId`."

In addition, we outlawed arbitrary creation of IDs by hiding the constructor.
They can only come from decoding a `Cat` from `decoder`, giving us at least some reason to believe that our frontend code handles IDs responsibly.

I like this *a lot* better already, but I'm not going to go into more benefits here since I want to get to other points in the design space.
(If you're unfamiliar with this technique, search for "primitive obsession" to see more examples. Learning about this will help you write better code!)

## Drawbacks of the Hidden-Constructor Custom Types

Even though we've made significant improvements to our code, they don't come for free.

First of all, we can no longer construct values of `Cat` in tests without deserializing some hand-coded JSON plus handling the error case.
This means that our tests are way more complex, plus they're now tied to the `decoder` instead of just the details we want to verify.
I've seen people argue in favor of this approach, but increasing the failure points of a test always makes me uneasy.

Second, due to Elm's design decisions you can't use `CatId` where the compiler expects something matching `comparable`.
This shows up pretty frequently because ideally we'd have fast (`O(log n)`) lookups by key in our cat collection and most implementations (like `elm/core`'s `Dict`) need to compare items to do a binary search.

But good news: the Elm community know about this (hopefully temporary) problem and has published a bunch of different packages to help get around it.
I like `rtfeldman/elm-sorter-experiment`, which asks us to define a custom sorter function and pass it to dictionary and set constructors.
For `CatId`, that looks like this:

```elm
idSorter : Sorter CatId
idSorter =
    Sort.by (\(CatId id) -> id) Sort.alphabetical
```

Now we can construct dictionaries and sets containing `CatId` for fast lookups and still get the type safety in the keys.

So far so good, right?
But this pattern has one last downside: you need to define `FooId`, `idSorter`, and (usually) `idDecoder` for every single resource type in your application.
Most of those definitions will look exactly the same except for the name of the type, and while I'm not against boilerplate as a whole (in fact, yay for being explicit!) this particular usage really annoys me.
Because I only define the functions I need when I need them, this appraoch tends to lead to many-file refactorings and leaves hanger-on functions if I forget I added something.

## Another Approach: Phantom Types!

Recently I built a little game for my son to learn his letters and decided to see if I could find a nicer way to solve id-as-string problem.
My goal was to find something in between the wild wild west of using primitives directly and the repetition of defining ID types for every resource.

And, I think I did!
The key insight: you can make a reusable ID type by using phantom types (that is, types with a variable that appears in the definition but not any of the constructors.)

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

Of course, this improvement still doesn't come for free.
`Id thing` is still not `comparable` so the sorter (or equivalent in your package of choice) is required.

You also lose some of the assurance that you're not constructing or matching on `Id` in places where you shouldn't be.
To put it another way, you can make a bad ID pretty easily: just call `Id "a hot dog is a salad"`.

You also can't embed the ID of a record in the record itself (doing so would be a recursive definition.)
I managed to get around needing this in my alphabet game, but if you need it, you just need a little type trick:

```elm
module Cat exposing (Id, Cat, decoder)

import Id
import Json.Decode exposing (Decoder)


{-| An module-internal identifier. Has to be a custom type instead of an
alias so the compiler can detect if it's being used improperly.
-}
type CatId
    = CatId


type alias Id =
    Id.Id CatId


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

So to sum up: with this technique, you get...

- nice type-checking and good errors (with really obvious fixes, like "you have a `Id Dog` but you need an `Id Cat`.")
- reasonable reuse patterns

But with these tradeoffs:

- You have to deal with `comparable` not being extendable by custom types.
- You have to be disciplined about not deconstructing/matching against IDs in places where it wouldn't make sense to take responsibility for constructing them.
- To get IDs in the records themselves (as opposed to just in `Dict`s or whatever) you have to do a (small) type trick.

So would I do this again?
As usual, *maybe*!

I think I would avoid using this in a project where I didn't have a high confidence that my fellow programmers knew the intent of the module.
That means that I wouldn't to publish a package using this, or contribute code to a high-traffic open source repo using this pattern.
But on my team, in private code, or in small apps that I build for myself, I'll definitely be coming back to this!
