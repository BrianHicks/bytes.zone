---
{
    "type": "post",
    "title": "elo-anything",
    "summary": "using the Elo rating system to sort items in our backlog.",
    "published": "2020-08-31T00:00:00-05:00"
}
---

I lead a team at work.
Part of that job is dealing with a big list of work that falls into my team's areas of ownership, but which we're not going to do immediately.
This work is a mix of small, non-blocking bugs (e.g. an animation that stopped working) and internal upgrades (e.g. tracking version upgrades in dependencies.)
Hypothetically, we should work on the most impactful tasks first, but in a list of 40 or 50 little things like this it's hard to know what's most important.

In fact, it turns out I find it pretty much impossible to pick the single most important thing out of such a long list!
This makes the job much harder!
After a recent quarter where we didn't accomplish any ownership work at all (screaming face emoji), something had to change.

To start off, I'm assuming we can get time allocated to maintenance / ownership work.
I've heard of (and been on) engineering teams that can't get time for this kind of thing, but that's not a huge deal for my team.
I have a good enough relationship with our stakeholders that they trust me if I say something needs to be worked on.
Plus, we've baked it into our schedules: at minimum, the team spends 15% of our time on ownership work in any given week.
(I save Fridays for this.
It's really nice to end the week by hammering out 4 or 5 quick bug fixes!)

But even with the time allocated, we can't really make progress if we don't know what to work on, so I set out to figure out how to select tasks from our big list.

## So what do we work on?

To start, whatever selection method needs to give me a rough order pretty quickly.
I can't choose the most important thing among 50 items; there are just too many things to keep in my head and I'll have to guess.
But it *is* possible if I'm picking from 10, or better yet 5, so getting even a rough order helps a lot!

Items get added to the list over time, too, so the method needs to handle that gracefully.
I don't want to do a billion comparisons for every new item to figure out exactly where it goes.
And again, a rough order is fine here.
This doesn't have to be extremely precise, just good enough to choose which things to work on next.

I'd also like the order to be able to change over time without having to re-sort the entire list.
If we learn something new or change our minds about where we want to focus, it should be easy to get a new order.

## The Elo rating system

Fortunately for us, there's something that solves these pretty well already: the [Elo rating system](https://en.wikipedia.org/wiki/Elo_rating_system)!
It defines a way to get a rough ranking of a big list as well as a way to adjust the ranks quickly when an item is over- or underrated.
It's been used to rank chess players basically forever, too, so I'm not starting from scratch on a novel algorithm!

To order a list of items (let's call them players to match the orignal use), you start with everyone at a given rating and start playing matches (in our case, comparing items in the backlog.)
When player wins, they take a portion of the losing player's rating proportional to their difference in rank.
That means that:

- When two players are evenly matched the winner's rating will go up by a little. There's not a lot of signal in wins or losses when players are evenly ranked: it could indicate a skill difference, but it could also be a fluke.
- If an underrated player wins against someone more highly ranked the underrated player's rating will go up a lot. A win here is higher signal: the winner could be underrated or the loser could be overrated. A fluke could still be possible, but adjustments like these will stabilize rankings over time: if you can consistently beat players ranked higher than you, you'll rise in the ranks.
- On the other hand, if a strong player wins against someone much lower ranked their score doesn't rise as much. It shouldn't be worth a lot of points to win against players you're expected to beat every time.

There's a little more to the math than that to adjust for scenarios where there are few matches played (like American Football) vs many (like Chess), but that's the basic idea.

So does it fit my criteria?

- A new or under-rated player can rise in the ranks quickly by challenging random higher-ranked players.
- The more comparisons we make in the list, the more the ranking stabilize.
- If we change our minds about something's importance, the rating can change relatively quickly.

Sounds like we're good!

## Ok! Let's use it!

To make a long story short, I built an Elm app to create and maintain these rankings for me, and you can use it right now at [elo.bytes.zone](https://elo.bytes.zone) (or get the source at [git.bytes.zone/brian/elo-anything](https://git.bytes.zone/brian/elo-anything).)

Some features:

- You can rank however many items you need, and add and remove them at any time.
- There's an undo button (which is helpful for second-guessing!)
- New items are treated specially. Ideally, they'll get to the right ranking in 5 matches or less, and the system favors selecting new items so you can get those five matches in quickly.
- You can load and save rankings in order to persist items over time.

I've been super happy to use this to sort our list, and now our ownership work is actually being accomplished!
A nice benefit that I hadn't anticipated: when I go through the list with my team's PM, we can have a productive conversation about the relative importance of *this* versus *that*, which has revealed new information about differences in our priorities!
Using this rating system has lead to a couple good conversations about what the team *should* be working on, which I've been really happy about.

Anyway, that's a wrap.
Let me know if you end up using elo-anything.
It's fairly polished at this point but I'm sure there are still weird edge cases we could find and fix!
