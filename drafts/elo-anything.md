---
{
    "type": "post",
    "title": "elo-anything",
    "summary": "using the Elo rating system to sort items in our backlog.",
    "published": "2020-08-31T00:00:00-05:00"
}
---

Part of my job as a team lead is dealing with a big list of work that my team is responsible for, but which we're not going to do immediately.
Hypothetically, this is work we should be doing all the time, but we're a small team with a lot of responsibility, so our list tends to grow.
We *should* work on the most impactful tasks first... but in a list of 40 or 50 little things, it's hard to know what's most important.
This makes the job much harder!

After a recent quarter where we didn't accomplish any ownership work at all (screaming face emoji), something had to change.
So I built a tool to help!

Before we continue, I'm assuming it's possible to get time allocated to maintenance/ownership work.
I've heard of (and been on) engineering teams that can't get this time, but that's not a problem my current team has.
I have a good enough relationship with our stakeholders that they trust me if I say something needs to be worked on.
Plus, we've baked it into our schedules: at minimum, the team spends 15% of our time on maintenance/ownership work in any given week.
(I save my Fridays for this.
It's nice to end the week by hammering out 4 or 5 quick bug fixes!)

But even with the time allocated, we can't make progress if we don't know what to work on, so I set out to figure out how to select tasks from our big list.

## So what do we work on?

To start, whatever selection method needs to give me a rough order pretty quickly.
I can't choose the most important thing among 50 items; there are just too many things to keep in my head and I'll have to guess.
But it *is* possible if I'm picking from 10, or better yet 5, so getting even a rough order helps a lot!

Items get added to the list over time, too, so the selection method needs to handle that gracefully.
I don't want to do a bajillion comparisons for every new item to figure out exactly where it goes.
And again, a rough order is fine here: this doesn't have to be extremely precise, just good enough to choose which things to work on next.

I'd also like the order to be able to change over time without having to re-sort the entire list.
If we learn something new or change our minds about where we want to focus, it should be easy to get a new order.

## The Elo rating system

Fortunately for us, there's something that solves for these constraints well already: the [Elo rating system](https://en.wikipedia.org/wiki/Elo_rating_system)!
It defines a way to get a rough ranking of a big list as well as a way to adjust the ranks quickly when an item is over- or underrated.
It's been used to rank chess players forever, too, so I'm not starting from scratch on a novel algorithm!

To order a list of items (let's call them players to match the original use), you start with everyone at a given rating and start playing matches. 
When a player wins, they take a portion of the losing player's rating proportional to the difference between the two ratings.
Then to get rankings, you simply sort players from the highest rating to lowest.

The algorithm used to determine the rating change says that:

- When two players are evenly matched, the winner's rating will go up by a little. There's not a lot of useful information in match outcomes when players are evenly ranked: a win could indicate a skill difference, but it could also be a fluke.
- If an underrated player wins against someone more highly ranked the underrated player's rating will go up a lot. A win here has more information: the winner could be underrated or the loser could be overrated. A fluke could still be possible, but adjustments like these will stabilize rankings over time.
- On the other hand, if a strong player wins against someone much lower-ranked their score doesn't rise as much. It shouldn't be worth a lot of points to win against players you're expected to beat every time.

There's a little more to the math to adjust for scenarios where there are few matches played vs many, but that's the basic idea.

Taken as a whole, these rules mean that if you consistently win you'll go up in ranking (or if you lose, you'll go down.)
Given enough matches, you tend to get a stable ordering of players according to their level!

So does the Elo rating system fit my criteria?

- A new or under-rated player can rise in the ranks quickly by challenging random higher-ranked players.
- The more comparisons we make in the list, the closer to the true order items will get.
- If we change our minds about something's importance, the rating can change relatively quickly.

Sounds like a plan!

## Ok! Let's use it!

To make a long story short, I built an Elm app to create and maintain these rankings for me, and you can use it right now at [elo.bytes.zone](https://elo.bytes.zone) (or get the source at [git.bytes.zone/brian/elo-anything](https://git.bytes.zone/brian/elo-anything).)

Some features:

- You can rank however many items you need, and add and remove them at any time.
- There's an undo button (which is helpful for second-guessing!)
- New items are treated specially. Ideally, they'll get to the right ranking in 5 matches or less, and the system favors selecting new items so you can finish those play-in matches quickly.
- You can load and save rankings to persist items over time.

I've been super happy to use this to sort our task list, and now our ownership work is consistently being accomplished!
A nice benefit that I hadn't anticipated: when I go through the list with my team's PM, we can have a productive conversation about the relative importance of *this* versus *that*, which has revealed new information about differences in our priorities!
Using this rating system has lead to a couple of good conversations about what the team *should* be working on, which I've been really happy about.

Anyway, that's a wrap.
Let me know if you end up using elo-anything.
It's fairly polished at this point but I'm sure there are still weird edge cases we could find and fix!
