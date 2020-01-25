---
{ 
  "type": "talk",
  "event": "Elm Europe",
  "title": "Let's Make Nice Packages!",
  "published": "2018-07-18T00:00:00-05:00"
}
---

This year at [Elm Europe](https://2018.elmeurope.org) I gave a talk called “Let’s Make Nice Packages!”

It’s about research.

No, wait, come back!

<youtube id="yVn7FOQuwDM"></youtube>

I really appreciate the opportunity to speak, and the conference was a blast! Elm Europe is worth attending, and I plan to be there myself next year if I can.

I cut a bunch of things from the talk in the interest of time. A few came up in conversation with people at the conference:

## Help People Along the Way

First, if you follow all of the advice in my talk, but *do not help anyone along the way*, you will still fail. You may be focused on the bigger problem, but you’ll have a much harder time solving it if you haven’t been involved in the smaller ones along the way.

When you help people with their problems, you’re building a relationship and trust with the people you’re working with. Everybody feels appreciated when someone takes the time not only to listen to them but to help them find a solution, even if it’s a short-term solution.

Compare you saying, “hey, we talked about this earlier, what if we tried this new thing?” to “hey random person, I made a thing for youuuuuuu!” Why should they believe that your solution will work for them if they’ve never heard from you before?

Practically speaking, participate in discussions on Slack, Discourse, and Reddit. Be helpful, empathetic, and kind. People really appreciate it!

## Publish Little Solutions

Second, this whole process leads pretty quickly to blogging. People tend to have the same problems, but not everybody will ask online. So if you compile small solutions to problems you’ve helped with, and put them where people can see them, you’re also building trust with people who you’ll never have to speak with directly.

## What If I Need New Language Features to Solve the Problem?

*Rarely* while you’re doing this, you find that you need something that Elm doesn’t have, and which you can’t add in a package. Native code comes up most frequently, but sometimes language extensions or new syntax proposals do too.

This is an excellent time to stop and talk with people about what you’re thinking about! Put stuff in the “Learn” or “Request Feedback” categories on Discourse or ask in #general or #api-design on Slack. And remember, communication is collaboration. These discussions are just as useful as writing code, if not more, as it will help prevent building the wrong solution.

### Check for the X/Y Problem

At the same time, check that you’re not hitting the [X/Y problem](http://xyproblem.info/). (And by the way, if your problem statement reads like “I don’t have access to some web platform API in Elm”, you definitely are. The problem is always deeper than not having access to a specific API.)

Fortunately, you can use your research to check this! As a specific exercise, try [5 Whys](https://www.isixsigma.com/tools-templates/cause-effect/determine-root-cause-5-whys/): just continue asking “why” until you get to the root of the problem. A nice first question is “what are people trying to do?”

If you can’t find the root problem in a satisfactory way, with concrete examples from people you’ve helped, then take it as a signal to reexamine your research.

### OK, I did all that and still can’t solve this problem without language extensions

Sometimes there are things that just can’t be done yet. Your research has revealed one in a concrete way. That’s helpful! Good job!

This means that it’s time to write up your research and share it (probably on the elm-dev mailing list.) You’ll need to include these three things:

1. the problem you’re trying to solve
2. the designs you tried, *without* language extensions
3. why those designs didn’t solve the problem

Be as clear and concise as possible, and take the time to format your message to be read. Use headings, lists, and a add quick summary at the top. It helps more than you’d realize!

At this stage, please don’t suggest solutions. The core team follows this design process too, including the deep research and thinking. At the language level, that research has a much bigger scope. New features usually need to solve several problems at once, so expect discussion and then a period of waiting. It’s better to do things *right* than *right now*.

## Note Organization

Finally, I like to organize my notes in Markdown like this. It helps me remember to fill out all the sections:

```markdown
# {Thread Title} by {author}

Summary or additional thoughts.

## Context

What are they trying to do?

## The Fix

Your suggestion for how to fix the initial problem.
Don't forget other people's suggestions as well!

## Pain

This is where relational language goes. The header
is "pain" for me since this is typically what
they're expressing.

## Questions

> verbatim quotes

## Worldview / Assumptions

> verbatim quotes
```

To close out: if you have any questions about any of this, I’m always happy to talk about it! You can find me on Slack at @brianhicks, or you can email me at [brian@brianthicks.com](mailto:brian@brianthicks.com).
