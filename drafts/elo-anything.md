---
{
    "type": "post",
    "title": "elo-anything",
    "summary": "using the Elo rating system to sort items in our backlog.",
    "published": "2020-08-31T00:00:00-05:00"
}
---

Part of my job as an engineering team lead is dealing with a big list of work that falls into my team's areas of ownership, but which we're not going to do *right now*.
This work is a mix of small, non-blocking bugs (e.g. an animation that stopped working) and internal upgrades (e.g. tracking modal versions in [noredink-ui](https://github.com/noredink/noredink-ui).)

We should work on the most impactful tasks first, but in a list of 40 or 50 little things like this it's hard to know what's most important.
Turns out I'm pretty bad at picking the single most important thing out of such a long list.
As a consequence, I realized earlier this year that we hadn't accomplished any of the tasks in the list all quarter because we didn't know what actually needed to be done!
Clearly something needed to change.

## So what do we want?

To start, some teams just can't get time for maintainance / ownership work.
Fortunately, that's not the case for us: if we know what needs to be done, it's pretty easy to make the case for us to spend time doing it.
That gets a lot easier when we can reliably say we're working on the most important things first, so I set out to figure out how to select those.

To start, I want to have something that will at least let me get a rough order quickly.
If I start from 50 items, I can't choose the most important thing: there are just too many things to keep in my head and I'll have to guess.
This task becomes easier if I'm picking from what I know are the top 5 or 10.

The same goes for new items: I don't want to do 50 comparisons for every new item to figure out where it goes.
Ideally, the system should tell me roughly where something should end up with minimum fuss.

I'd also like the order to be able to change over time without having to re-sort the entire list.
If we learn something new about one of the stories, or change our mind about the places we want to focus, it should be easy to get a new order.

## The Elo rating system

Fortunately for us, there's something that solves these pretty well already: the [Elo rating system](https://en.wikipedia.org/wiki/Elo_rating_system)!
It defines a way to get a rough ranking of a big list as well as a way to adjust the ranks quickly when an item is highly over- or under-rated.
It's been used to rank chess players basically forever, too, so I'm not starting from scratch on a novel algorithm!

To order a list of items (let's call them players since it's a little easier to think about that way), You start with everyone at a given rating (say 1,200) and start playing matches (or doing comparisons between items in our backlog.)
When player wins, they take a portion of the losing player's rating according to the difference between them.
When two players are evenly matched (say they both have 1200) the winnner's rating will go up by a little, but if an underrated player wins against someone more highly ranked the change will be much bigger.

There's a little more to the math than that, but that's the basic idea.

So does it fit my criteria?

- A new player compared against random higher-ranked players will go up quickly if it's under-rated.
- The more comparisons we make in the list, the closer the rankings get to the truth. If we change our minds about something's importance, the rating changes relatively quickly.

## Ok! Let's use it!

To make a long story short, I built an Elm app to create and maintain these rankings for me, and you can use it right now at [elo.bytes.zone](https://elo.bytes.zone) (or get the source at [git.bytes.zone/brian/elo-anything](https://git.bytes.zone/brian/elo-anything).)

Some features:

- You can rank however many items you need, and add and remove them at any time.
- There's an undo button (which is helpful for my second-guessing!)
- New items are treated specially. Ideally, they'll get to the right ranking in 5 matches or less, and the system favors selecting new items so you can get those five matches in quickly.

I've been super happy to use this to sort our list, and now our ownership work is actually being accomplished!
A nice benefit that I hadn't anticipated: when I go through the list with my team's PM, we can have a productive conversation about the relative importance of *this* versus *that*, which has revealed new information about differences in our priorities!
Using this rating system has lead to a couple good conversations about what the team *should* be working on, which I've been really happy about.

Anyway, that's a wrap.
Let me know if you end up using elo-anything; it's fairly polished at this point but I'm sure there are still weird edge cases we could find and fix!
