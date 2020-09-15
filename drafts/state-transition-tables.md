---
{
  "type": "post",
  "title": "state-transition tables and update functions",
  "summary": "Elm's update functions are also secretly state transition tables.",
  "published": "2020-08-31T00:00:00-05:00",
}
---

I was reading some Wikipedia the other day (as you do) and found out about [state-transition tables](https://en.wikipedia.org/wiki/State-transition_table)

Basically, state transition tables show how a state machine transitions between different states.
It's an alternative to drawing a [state diagram](https://en.wikipedia.org/wiki/State_diagram) that lends itself well to machine analysis.

Wikipedia shows some pretty abstract tables, so I'm going to model a simple vending machine instead.
The "happy path" here is:

1. put a quarter in
2. press the button for the drink you want
3. get the drink

We have to manage two independent pieces of state with this: whether you have enough money to vend, and whether you have enough drinks to serve.

The one-dimensional form of a state-transition table is the easiest to understand: we have a column each for input, state, next state, and output.
For a vending machine, it might look like this:

| Input          | Current State           | Next State              | Output     |
|----------------|-------------------------|-------------------------|------------|
| Insert Quarter | No Money, Some Drinks   | Some Money, Some Drinks |            |
| Hit Button     | Some Money, Some Drinks | No Money, Some Drinks   | Vend Drink |

But, of course, we have to model what happens when we do thing that are not on the happy path.
It's not super obvious what all the states are in this example!
So, state-transition tables typically have two dimensions, where one dimension is the current state and the other is the input.
Our next state and output live in the cells (I've separated them with a `/`):

| ↓ Current State / Input → | Insert Quarter                    | Hit Button                         |
|---------------------------|-----------------------------------|------------------------------------|
| No Money, Some Drinks     | Some Money, Some Drinks / Nothing | -                                  |
| Some Money, Some Drinks   | -                                 | No Money, Some Drinks / Vend Drink |
| No Money, No Drinks       | -                                 | -                                  |
| Some Money, No Drinks     | -                                 | -                                  |

Whoops! When we look at it this way, we can see that we've only defined two of the possible 8 states!
Writing things down in an orderly way revealed that we haven't specified nearly all of our system.
Let's fill the rest out:

| ↓ Current State / Input → | Insert Quarter                    | Hit Button                         |
|---------------------------|-----------------------------------|------------------------------------|
| No Money, Some Drinks     | Some Money, Some Drinks / Nothing | No Change / Beep                   |
| Some Money, Some Drinks   | No Change / Refund Quarter        | No Money, Some Drinks / Vend Drink |
| No Money, No Drinks       | No Change / Refund Quarter        | No Change / Beep                   |
| Some Money, No Drinks     | ???                               | ???                                |

But if we do that, we can see that we have a potentially weird situation: what if we somehow have some money, but no drinks?
The state machine should prevent that, since there's no new state field that could create this situation.
But it's feasible to get there either via programming (for example, by modeling the data as two independent fields) or hardware issues (for example, someone prying open the machine to leave quarters in an atypical act of vandalism.)

Our modeling has revealed this way before we got to the code parts of our application, and the hardest part (for me, at least) was formatting Markdown tables.
Now I can take this same table and either go talk about it with my engineering team or raise it as an ambiguous part of the specification.

I'd call that a win for just a little time spent modeling!

(oh, and bonus: if you're using Elm, the 1-dimensional form here is probably pretty familiar.
"Input, Current State, Next State, Output" does the same job as `update : msg -> model -> ( model, Cmd msg )`!)

TODO: mention that you can change the dimensions (current state / next state) to make it clearer that there's some missing input here.
