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
It's an alternative to drawing a [state diagram](https://en.wikipedia.org/wiki/State_diagram) that lends itself well to machine analysis.

Wikipedia shows some pretty abstract tables, so I'm going to model a vending machine instead.
To simplify things, we'll serve a single drink for a single quarter.
The idealized version of the interaction with this machine is:

1. put a quarter in
2. press the button for the drink you want
3. get the drink

We have to manage two independent pieces of state with this: whether you've put money in the machine and if it has at least one drink left to vend.

Let's model the happy path above with a one-dimensional state-transition table.
This form keeps the modeling as simple as possible while still capturing enough detail to be useful: we have a column each for input, state, next state, and output.
To find out what happens after an event, you just find the input and current state in rows and look at matching next state and output.
For our vending machine, it might look like this:

| Input          | Current State           | Next State              | Output     |
|----------------|-------------------------|-------------------------|------------|
| Insert Quarter | No Money, Some Drinks   | Some Money, Some Drinks |            |
| Hit Button     | Some Money, Some Drinks | No Money, Some Drinks   | Vend Drink |

But, of course, we have to model what happens when we do thing that are not on the happy path.
Unfortunately, the one-dimensional version of the table doesn't give us a great view of that!

To figure out where we have holes, we need to add more dimensions.
If we reorganize our states and inputs along along the axes of a table, we get a two-dimensional state-transition table.
According to Wikipedia, these are the more common form anyway!

To read this table, match the current state along one axis with the input along the other.
Our next state and output live in the intersections (I've separated them with a `/`):

| ↓ Current State / Input → | Insert Quarter                    | Hit Button                         |
|---------------------------|-----------------------------------|------------------------------------|
| No Money, Some Drinks     | Some Money, Some Drinks / Nothing |                                    |
| Some Money, Some Drinks   |                                   | No Money, Some Drinks / Vend Drink |
| No Money, No Drinks       |                                   |                                    |
| Some Money, No Drinks     |                                   |                                    |

Whoops!
When we look at it this way, we can see that we've only defined two of the possible 8 outcomes!
Writing things down in an orderly way revealed that we haven't specified all of our system.
Let's fill the rest out:

| ↓ Current State / Input → | Insert Quarter                    | Hit Button                         |
|---------------------------|-----------------------------------|------------------------------------|
| No Money, Some Drinks     | Some Money, Some Drinks / Nothing | No Change / Beep                   |
| Some Money, Some Drinks   | No Change / Refund Quarter        | No Money, Some Drinks / Vend Drink |
| No Money, No Drinks       | No Change / Refund Quarter        | No Change / Beep                   |
| Some Money, No Drinks     | ???                               | ???                                |

But if we do that, we can see that we have a potentially weird situation: what if we somehow have some money, but no drinks?
The state machine should prevent that, since there's no new state field that could create this situation.
But it's feasible to get there either via programming (for example, by modeling the state as two independent fields) or hardware issues (for example, someone prying open the machine to leave quarters in an atypical act of vandalism.)

Our modeling has revealed this way before we got to the code parts of our application, and the hardest part was making a table and thinking.
Now I can take this same table to a stakeholder or domain expert and have a productive conversation about what they think should happen.

I'd call that a win for just a little time spent modeling!

(oh, and bonus: if you're using Elm, the 1-dimensional form here is probably pretty familiar.
"Input, Current State, Next State, Output" does the same job as `update : msg -> model -> ( model, Cmd msg )`!)
