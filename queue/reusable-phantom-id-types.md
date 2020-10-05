---
{
  "type": "post",
  "title": "Phantom ID Types",
  "summary": "Another point in the design space of avoiding primitive obsession in IDs.",
  "published": "2020-08-31T00:00:00-05:00",
}
---

I previously wrote about tradeoffs of custom ID types in Elm, and promised to explore a few points in the space.
This is one!

Recently I built a little game for my son to learn his letters and decided to see if I could find a nicer way to solve id-as-string problem.
My goal was to find something in between the wild wild west of using `String`s directly and the repetition of defining ID types for every resource.

Anyway, I found something new to me.
Maybe it'll be useful to you, too!
The gist: **you can make a reusable ID type by using phantom types** (that is, types with a variable that appears in the definition but not any of the constructors.)

Let's define a module for our IDs:

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
`Id thing` is still not `comparable` so you need a workaround if you want to use it in a `Dict` or `Set` (`sorter` above.)

You also lose some of the assurance that you're not constructing or matching on `Id` in places where you shouldn't be.
To put it another way, you can make a bad ID pretty easily: just call `Id "a hot dog is a salad"`.
Because the type is not used in the constructor, that's a valid *whatever*... `Id Cat`, `Id Dog`, it's all the same to the constructor.

You also can't embed the ID of a record in the record itself (doing so would be a recursive definition.)
I managed to get around needing this in my alphabet game (records do not need to refer to themselves because whenever they're displayed there's another piece of data containing the ID.)
If you need it, you just do a little type trick:

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
```

All the instances of `CatId` should be erased during compilation.
That is, they shouldn't end up adding any weight to your compiled JavaScript!

And there you have it!
To sum up: with this technique, you get the normal stuff you get by using custom types as IDs, like:

- nice type-checking and good errors (with really obvious fixes, like "you have a `Id Dog` but you need an `Id Cat`.")
- reasonable levels of code reuse

But with these tradeoffs:

- You have to deal with `comparable` not being extendable by custom types (which is true without a phantom type, too.)
- You have to be disciplined about not deconstructing/matching against IDs in places where it wouldn't make sense to take responsibility for constructing them.
- To get IDs in the records themselves (as opposed to just in `Dict`s or whatever) you have to do a type trick.

So would I do this again?
It's a big maybe!

I think I would avoid using this in a project where I didn't have a high confidence that my fellow programmers knew the intent of the module.
That means that I wouldn't to publish a package using this, or contribute code to a high-traffic open source repo using this pattern.
But on my work team in private code, or in small apps that I build for myself, I'll definitely be coming back to this!
