---
{
    "type": "post",
    "title": "elo-anything",
    "summary": "TODO: summary",
    "published": "2020-08-31T00:00:00-05:00"
}
---

Part of my job as a team lead at NoRedInk ([we're hiring!](https://www.noredink.com/jobs)) is dealing with a big list of work that falls into my team's areas of ownership, but aren't things we're going to do *right now*.
These are a mix of small, non-blocking bugs (e.g. an animation that stopped working) and internal upgrades (e.g. upgrading modals to the latest version of [noredink-ui](https://github.com/noredink/noredink-ui).)

We should work on the most impactful tasks first, but in a list of 40 or 50 little things like this how do we know what's most important?
Turns out I'm pretty bad at picking the single most important thing out of such a long list.
And as a consequence, I realized earlier this year that we hadn't accomplished any of the tasks in the list all quarter because we didn't know what actually needed to be done!
Clearly something needed to change.

## So what do we want?

I realized that it's pretty easy to schedule work if we can figure out what work to schedule, so I spent some time thinking about how to select work.

To start, I want to have something that will at least let me get a rough order quickly.
If I start from 50 items, I can't choose the most important thing, but it's way easier to choose the best thing out of 5 or 10.
The same goes for new items: I don't want to do 50 comparisons for every new item to figure out where it goes.

I'd also like the order to be able to change over time without having to re-sort the entire list.
If we learn something new about one of the stories, or change our mind about the places we want to focus, it should be easy to get a new order.

Those two characteristics together made me think about the Elo rating system.

## Ok, what's the Elo rating system?

The [Elo rating system](https://en.wikipedia.org/wiki/Elo_rating_system) defines a way to get a rough ranking of a big list as well as a way to adjust the ranks quickly when an item is highly over- or under-rated.
It's been used to rank chess players basically forever!

To order a list of items, You start with all your items at a given rating (say 1200) and start comparing them.
When an item wins, it takes a portion of the losing items rating according to the difference between them.
When two items are evenly matched (say they both have 1200), the winning item will go up by a little and the losing down by the same.
But when they're unevely matched (say one has 2000 and the other 1000) the difference will be much greater.

There's a little more to the math than that, but that's the basic idea.

So does it fit my criteria?

- A new item compared against random higher-ranked items will go up quickly if it's under-rated.
- The more comparisons we make in the list, the closer the rankings get to the truth. If we change our minds about something's importance, the rating changes relatively quickly.

## Ok! Let's use it!

To make a long story short, I built an Elm app to create and maintain these rankings for me, and you can use it right now at [elo.bytes.zone](https://elo.bytes.zone) (or get the source at [git.bytes.zone/brian/elo-anything](https://git.bytes.zone/brian/elo-anything).)

Some features:

- You can rank however many items you need, and add and remove them at any time.
- There's an undo button (which is helpful for my second-guessing!)
- New items are treated specially. Ideally, they'll get to the right ranking in 5 matches or less, and the system favors selecting new items so you can get those five matches in quickly.
