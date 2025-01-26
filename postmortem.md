# Game Postmortem: Jovian Ship Self Defense Simulator 1993

## Clock-In

### Why This?
I wanted to make something simple for my first game, and had an idea for a single screen game based on a [Multi Function Display](https://en.wikipedia.org/wiki/Multi-function_display), this way I wouldn't have to make a complex UI system. This had the unintended, though not unpleasant, side effect of making me try to make everything diagetic.

The interface is presented as an entirely diagetic UI for a [Ship Self Defense System](https://en.wikipedia.org/wiki/Ship_Self-Defense_System) and the player as it's newly hired operator. The game description is a realistic job posting promising on-the-job training, and the game presents itself as the incidents encountered by the employee during their year long contract. 

### But How Does That Make You *Feel*?
Given the framing, the player is expected to know how to operate their workstation and the provided ordnance. ~~This also frees me from having to learn how to make a proper tutorial.~~ Half the game is just figuring out how the controls work and what each munition does. Is it fun? Probably not, but fun wasn't *really* part of the intended experience. If the player feels stressed, overwhelmed, lost, confused, a little frustrated, like they didn't get proper training to do this stressful job, then it is working as intended.

### A Well-Intended Anti-Tutorial
The player is initially shown a bland boot screen and has to learn the basics of the interface in order to start the first level, which practically serves as a controls tutorial.

When starting the first level, the player is shown the radar screen. They are given a few seconds to familiarize themselves with the screen before an alarm blares and red lights labeled "warning" start blinking. Then an ominous ping sounds and a new line appears on the radar screen. Between these cues and the framing, the player should understand a missile was just launched at them, prompting them to take action. They are only given one munition (which will destroy the incoming missile), they will have to learn how to launch the munition, and after launching it their bonus eligibility tracker will blink and go down by 10 thousand. This level introduces all the basic mechanics of how to deploy countermeasures, what signals you receive that would prompt deploying them, and that there is a cost associated with deploying them, all without any explicit tutorial. I think it is a perfectly servicable bit of on-the-job training.

### Mechanical Mastery(?)
Later levels expand on the mechanics, adding non-destructive (soft-kill) countermeasures and different missile types suseptible to those countermeasures, forcing the player to learn how to differentiate between the missile types for optimal play.

### Design Choices
The workplace framing makes the game relatable, as everyone has experienced stress and anxiety at work. The single-screen design dramatically simplified development, keeping the scope small for a first game. Keeping everything diagetic added to the sense that this is your workstation, and it behaves exactly like a poorly designed, low-budget workstation might behave in a cost-saving, corner-cutting industry. The end game screen, whether you complete your contract or not, highlights the desperate nature of the post cold war Jovian job market. Try to "Quit" or "Clock-In" after both dying and completing your contract, I think it's a fun little touch.

### Godot
The Godot engine was a pleasure to work with. I haven't tried others yet, but the simplicity, community, and availability of tools and guidance made it an excellent choice. It being open source and my intent to release the source code of my own game made it an obvious choice.

## What Went Right

### I Actually Released Something
One of the primary goals was simply to make and release the game. Participating in the Portland Indie Game Squad's "Finish Your Game" Jam in November 2024 was instrumental in achieving this. The community support and the structured environment of the jam helped overcome my tendency to abandon projects. The game wouldn't exist without the encouragement and support from the PIGSquad community.

### In Doing So I Learned A Lot
Since this was Baby's First Game coming from a mostly backend web development background, I was learning game development, Godot, UI development, and game design generally. I was commited to keeping the game small, and simple so I could focus on learning things to help me make better games in the future. I definitly learned a lot, and I think I have a better idea of what I want to do next time, and probably more importantly what I don't want to do next time, looking at you [ui\display.gd](ui\display.gd)

### Let Me Tell You About My Fixation On Missile Guidance Systems
The missile guidance system had to be custom-made due to the unique requirements of a realistish space simulation. Available guides for programming game missiles assume instant acceleration and a max speed, while my intent was to have constant acceleration and no top speed, this being a grounded space game. After implementing a few of the tutorials I found, I'd get either:
- missiles that orbited their target if they applied a constant acceleration in the direction of the target. It was neat to realize I created a cute little toy solar system model though, with the target as the central body and the missile as an orbiting body.
- missiles that would simply miss their target, as they were accelerating towards where they expected the target to be, but were not accounting for their initial relative velocity.

To both account for and preserve as much momentum as possible, I implemented a vector projection guidance algorithm. Now the missile calculates the direction it needs to burn based on how much fuel it has, and the relative velocity that is not aligned with the direction to the expected impact location. The result is a single burn in a mostly straight line (there is a configurable coeffecient to tell the missile to overshoot the desired velocity rejection) that will get the missile to the target's expected location at the time of impact. This results in a realistic behavior, akin to what you'd expect in a hard sci-fi setting. I had experimented with a [Proportional Navigation](https://en.wikipedia.org/wiki/Proportional_navigation) implementation for this, but it only worked under the assumption of a max speed. It was unfortunate since the implementation was particularly elegant and mirrors modern anti-aircraft missile algorithms. I left the code in place because I couldn't bring myself to delete it, which worked out great because I was able to use it for the midcourse stage of the missile's flight, when it is done accelerating and is coasting to the target.

I the future I'd like to implement a more realistish system, which takes data from an onboard radar system, and uses that to guide the missile, instead of the missile having perfect knowledge of the target's position and velocity. This would especially be relevant for seekers that do not get velocity data, like a passive infrared or Anti-Radiation seeker. Also of interest would be setting up a system to train a few ML models to guide the missile, and see how they perform. I quite like genetic algorithms, and I think it would be fun to see how they perform in this context.

### (Some) Players Loved It
During a PIGSquad showcase, one player remarked upon seeing the job description that the game was "too real" and after playing they "loved how much they hated it." This feedback was particularly gratifying as it communicated the exact feeling of workplace anxiety I was aiming for. It reinforced that the game successfully conveyed the intended experience.

### PIGSquad Is Great
Working on the game during the PIGSquad jam helped me connect with the community, providing the support needed to complete the project. The encouragement and feedback from fellow developers and players was crucial in maintaining motivation and pushing through to the end, and actually, finally, releasing something.

## What Went Wrong

### I Don't Know What I'm Doing
The biggest challenges I faced were due to my general ignorance of game development, UI development, and especially game UI development. While I did follow some decent composition practices, [the code running the UI](ui\display.gd) was set up "temporarily" as a basic state system with match cases to determine what each button did based on the state. It was not, in fact, temporary, and each time I had to expand it I promised myself I would fix it instead. But faced with the time constraints of the game jam, I ended up rolling with it the whole way through. It is the part I am most inclined to fix still, but it wouldn't really add anything to the experience of the game, so I'll call it done.

### I Wanted To Make It Worse
I had planned to have all of the screens be busier and more cluttered, but between the time constraint and players already struggling to parse the available information it ended up not being possible or necessary.

### The Scoring System Is A Complete Afterthought
I needed to motivate the player to be efficient with their resources, but didn't have any other feedback into the game, so vaguely gesture at a family to look after. I plan to recycle a lot of these systems for a more resource management sytled game, so it will get fleshed out there.

### (Most) Players Hated It
Many players bounced off the game quite hard due to the lack of a tutorial. Some wouldn't even make it into the first level, others couldn't figure out what to do when they got there. That was fine, I wasn't going for a broad appeal, mostly something I would enjoy making and playing, and a few players also greatly enjoyed it.

## Lessons Learned
### Just Do It Right The First Time
I *really* should have fixed the UI code when I had the chance. It would have made the game easier to expand and maintain, and I wouldn't have to look at it and feel a ~~great deal~~ little bit of shame. So many scraps of paper trying to parse what I needed to change where, oof. Similar, but to a lesser extent, the level definition code is bad and I should have stuck with the original plan of a level class similar to the missile and ship classes, but it was a rush job.

### Just Do It Wrong The First Time
To be fair to myself I may not have gotten the game done at all, and almose certainly not on time if I'd taken the time to also learn state machines in godot on top of everything else. In the end I'm proud of what I made, and I learned a lot, so I'm not too upset about it. Plus not I know about some helful state machine plugins, so can have make other horrible mistakes in the future.

### Keep It Simple
Keeping the scope small and not allowing myself to keep adding all those excellent ideas I was coming up with made it possible to actually finish the thing. Now my next game can be a bit bigger. It sort of mirrors the progression of the game.

### Community Support
Portland's great, simple as. PIGSquad's great, simple as. Most importantly, my partner's great, simple as.

## Future Improvements
### UI
The UI really should be fixed.

### Level Definition
The level definitions really should be fixed.

### Scoring System
The scoring system really should be... actually it's probably fine given the scope, its just a little underdeveloped.

### Better Thought Out Levels
Half the levels are just a tutorial, the remaining levels are tests of what was learned, but are still extremely simple and rely on overwhelming the player to make things interesting.

## Clock-Out
### I Did It
I started a thing, and more importantly I finished a thing. Now I need to do it again and start a habit of finishing things.

### I Now Know How To Make A Game (Game?)
So I can do it again, and better this time.