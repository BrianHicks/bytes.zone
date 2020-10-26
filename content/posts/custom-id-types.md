---
{
    "type": "post",
    "title": "Tradeoffs of Custom ID Types in Elm",
    "summary": "Custom ID types are great, but what are you giving up? Is it worth it?",
    "published": "2020-10-26T16:17:00-05:00"
}
---

In Elm, we store data in records.
Here's a model to define a `Cat`.
Mew!

```elm
module Cat exposing (Cat)


type alias Cat =
    { id : String
    , name : String
    , purriness : Int
    }
```

This particular implementation has a problem: you can do *whatever* with `id` since it's a `String`.
Wanna concatenate it with another one?
Go right ahead.
Regex match?
Why not!
Using a `String` here means that the compiler can't tell you if you're using the `id` in the way it was intended to be used.

One name for this is [primitive obsession](http://wiki.c2.com/?PrimitiveObsession), meaning code uses a language primitive (`String` here) instead of a domain-specific object.
This can make it harder to reason about and refactor the code, not to mention the fact that it doesn't guard against the problems above.

## A Custom Type

We can fix this in Elm by making a custom ID type:

```elm
module Cat exposing (Cat, CatId)


type CatId
    = CatId String


type alias Cat =
    { id : CatId
    , name : String
    , purriness : Int
    }
```

With this, you get pretty much all the benefits of wrapping a primitive in a class in other languages:

- we can distinguish between a `CatId` and a (hypothetical) `DogId`. Before defining a type, these would have both been `String`s and totally indistinguishable.
- We've disallowed `String` operations on the type. There will be no more concatenation, regex matching, et cetera.
- If we don't export the `CatId` constructor, nobody outside the `Cat` module can construct a value of `CatId`. With this setup, we can be pretty safe trusting values of `CatId` have been constructed in safe ways (for example, that they've been deserialized from JSON provided by the server.)

The benefits have been well-documented elsewhere and are (in my opinion) pretty unambiguous, so I'm keeping this brief.
I want to spend more time talking about the drawbacks of doing it in this particular way and how to get around them!

## Testing is Harder

First of all, we can no longer construct values of `CatId` in tests.
This means we cannot construct any records or structures that depend on `CatId` either.
No `Cat`, no `Model` containing `Cat`s, etc.

I've seen some test code provide hand-rolled JSON values to a `Decoder Cat` to get around this, but I'm not sure that's such a good idea.
It raises complexity in tests and ties them to the `decoder` instead of only the implemenation we're trying to verify.

Instead, I usually end up writing some constructor function like `catIdForTestOnly : String -> CatId`.
It has the same effect as exposing the constructor, but labels your intent clearly.

I'd call this pragmatic, but I know there are reasonable people who'd call it a code smell.
That's fine!
We can disagree!
But, regardless of your approach, you'll have to deal with the tradeoff of the hidden constructor here.

## No `comparable` Implementation

Second, you can't use `CatId` where the compiler expects something matching `comparable`.
This shows up pretty frequently because `elm/core`'s `Dict` needs keys to be `comparable` in order to provide fast lookups.

Fortunately for us, the Elm community know about this (hopefully temporary) problem and has published a bunch of different packages to help get around it.
I like `rtfeldman/elm-sorter-experiment`, in which we just need to define a custom sorter function and pass it to dictionary and set constructors.
For `CatId`, that looks like this:

```elm
idSorter : Sorter CatId
idSorter =
    Sort.by (\(CatId id) -> id) Sort.alphabetical
```

Now we can construct dictionaries and sets containing `CatId` for fast lookups and still get the benefits we want.

## Wrapping Up

So, that's one way to make sure you're doing the right things with IDs (or other small data) in your Elm code.

Should you do it?
I think that despite the tradeoffs, it's a **yes** most of the time!
I've had a lot of success with doing this, and I'd recommend it to others.

That said, there are some more ways to solve this problem, and I'm planning on exploring them in future posts.
