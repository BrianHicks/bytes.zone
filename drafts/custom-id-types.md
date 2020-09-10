---
{
    "type": "post",
    "title": "Custom ID Types in Elm",
    "summary": "Help make sure your data IDs are being used correctly.",
    "published": "2020-08-31T00:00:00-05:00"
}
---

In Elm, we often define records for remote data like this:

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

We might construct instances of `Cat` by hand (in tests, for example) but more often we load them from a server.

But I show this code to show a problem: you can do *whatever* with that ID string.
Concatenate it with another one?
Yup.
Regex match?
Why not!
Using a `String` here means that the compiler can't tell you if you're using the `id` in the way it was intended to be used.

Folks sometime call this [primitive obsession](http://wiki.c2.com/?PrimitiveObsession), meaning code uses a language primitive (`String` here) instead of a domain-specific object.
This can make card harder to reason about and refactor.
Like I said above, what's to keep you for writing a regex match against `id`?
Nothing!

So, let's see about fixing this.

## A Custom Type

To fix this in Elm, we can make a custom opaque ID type.
Note that `CatId` below does not expose its constructor (`CatId` instead of `CatId(..)` in the `exposing` line up top.)

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

Now the type system prevents us from doing arbitrary `String` operations on IDs.
Goal accomplished!

This has some other nice benefits as well: for example, we could define the route to get a `Cat` in our API.

```elm
apiRoute : CatId -> String
apiRoute (CatId id) =
    Url.Builder.absolute [ "api", "cats", id ] []
```

Only a `CatId` will be accepted here; anything else will result in a friendly error message.

In addition, by hiding the constructor we outlawed arbitrary creation of IDs.
Now you can only get a `CatId` by decoding a `Cat` from `decoder`.
This gives us at least some reason to believe that our frontend code handles IDs responsibly.

## Drawbacks

Even though we've made significant improvements to our code, they don't come for free.

### Testing is Harder

First of all, we can no longer construct values of `CatId` in tests without deserializing *some* JSON (maybe hand-coded?) plus handling the error case.
This means we cannot construct any records or structures that depend on `CatId` either.
No `Cat`, no `Model` containing `Cat`s, etc.
This means that our tests are way more complex and become tied to the `decoder` in addition to the details we want to verify.

I've seen people accept this, but increasing dependencies in test code always makes me uneasy.
I usually end up writing some constructor function like `catIdForTestOnly : String -> CatId`.
It has the same mechanical effect as exposing the constructor, but labels your intent clearly.
Assuming you do only use it in tests, The Elm compiler will remove it as unused code durng compilation so there's no runtime cost.

I'd call this pragmatic, but I know there are reasonable people who'd call it a code smell.
That's fine!
We can disagree!
But, regardless of your approach, you'll have to deal with the tradeoff of the hidden constructor here.

### No `comparable` Implementation

Second, due to Elm's design decisions you can't use `CatId` where the compiler expects something matching `comparable`.
This shows up pretty frequently because `elm/core`'s `Dict` needs keys to be `comparable` in order to provide fast lookups.

Fortunately for us, the Elm community know about this (hopefully temporary) problem and has published a bunch of different packages to help get around it.
I like `rtfeldman/elm-sorter-experiment`, in which we just need to define a custom sorter function and pass it to dictionary and set constructors.
For `CatId`, that looks like this:

```elm
idSorter : Sorter CatId
idSorter =
    Sort.by (\(CatId id) -> id) Sort.alphabetical
```

Now we can construct dictionaries and sets containing `CatId` for fast lookups and still get the type safety in the keys.

## Wrapping Up

So, that's one way to make sure you're doing the right things with IDs (or other small data) in your Elm code.

There are other ways to do this for sure, so, should you use this one?
I think **yes**!
I have had a lot of success with this.

TODO: rest of the conclusion.
