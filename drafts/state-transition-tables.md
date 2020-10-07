---
{
  "type": "post",
  "title": "state-transition tables",
  "summary": "A simple exercise to check our thinking about state.",
  "published": "2020-08-31T00:00:00-05:00",
}
---

I was reading Wikipedia the other day (as you do) and found out about [state-transition tables](https://en.wikipedia.org/wiki/State-transition_table).

Basically, state transition tables show how a state machine transitions between different states.
It's an alternative to drawing a [state diagram](https://en.wikipedia.org/wiki/State_diagram) that stays readable and helps you find holes in your logic.

Wikipedia shows some pretty abstract tables, so I'm going to model a vending machine instead.
To simplify things, we'll serve a single drink for a single quarter.
The idealized version of the interaction with this machine (the "happy path") is:

1. Put a quarter in
2. Press the button for the drink you want
3. Get the drink

To implement this, we have to manage two independent pieces of state: whether you've put money in the machine and whether it has at least one drink left to vend.

Let's model the interaction above with a one-dimensional state-transition table.
Using only one dimension keeps the modeling as simple as possible while still capturing enough detail to be useful: we have a column each for input, state, next state, and side effects.
To find out what happens after an event you just find the input and current state rows you care about and look at the matching next state and side effect.
For our vending machine, it might look like this:

| Input          | Current State           | Next State              | Side Effect |
|----------------|-------------------------|-------------------------|-------------|
| Insert Quarter | No Money, Some Drinks   | Some Money, Some Drinks | -           |
| Hit Button     | Some Money, Some Drinks | No Money, Some Drinks   | Vend Drink  |

But, of course, we have to model what happens when we do things that are not on the happy path.
Unfortunately, the one-dimensional version of the table doesn't give us a great view of that!

To figure out where we have holes, we need to add more dimensions.
Let's reorganize our states along the vertical axis and inputs along the horizontal axis to get a two-dimentional state-transition table.

To read this table, match the current state along the vertical axis with the input along the horizontal.
Our next state and side effects live in the intersections (I've separated them with a `/`):

| ↓ Current State / Input → | Insert Quarter                    | Hit Button                         |
|---------------------------|-----------------------------------|------------------------------------|
| No Money, Some Drinks     | Some Money, Some Drinks / Nothing |                                    |
| Some Money, Some Drinks   |                                   | No Money, Some Drinks / Vend Drink |
| No Money, No Drinks       |                                   |                                    |
| Some Money, No Drinks     |                                   |                                    |

And we see, uh... problems.
When we look at things this way, it's clear that we've only defined two of the possible 8 outcomes!
Writing things down in an orderly way revealed that we haven't specified all of the possibilities implied by our modeling.

Let's fill the rest out.
To make things easier, when the state stays the same or there's no side effect I've marked `-`:

| ↓ Current State / Input → | Insert Quarter                    | Hit Button                         |
|---------------------------|-----------------------------------|------------------------------------|
| No Money, Some Drinks     | Some Money, Some Drinks / -       | - / Beep                           |
| Some Money, Some Drinks   | - / Refund Quarter                | No Money, Some Drinks / Vend Drink |
| No Money, No Drinks       | - / Refund Quarter                | - / Beep                           |
| Some Money, No Drinks     | ???                               | ???                                |

But when we fill things out, we can see that we have a potentially weird situation: what if we somehow have some money, but no drinks?
The state machine should prevent that, since there's no new state field that could create this situation.
But it's feasible to get there either via programming (for example, by modeling the state as two independent fields) or hardware issues (for example, someone prying open the machine to leave quarters in an atypical act of vandalism.)

Our modeling has revealed this undefined behavior way before we got to the code parts of our application, and the hardest part was making a table and looking for empty cells.
Now I can take this same table to a stakeholder or domain expert and have a productive conversation about what they think should happen.

I'd call that a win for just a little time spent modeling!

(oh, and bonus: if you're using Elm, the one-dimensional form here is probably pretty familiar.
"Input, Current State, Next State, Output" does the same job as `update : msg -> model -> ( model, Cmd msg )`!)
