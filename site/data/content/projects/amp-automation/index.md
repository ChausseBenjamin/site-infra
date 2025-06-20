---
title: "Amp Automation"
date: 2023-10-25T20:01:27-04:00
tags: ["Shool Projects"]
---

My parents music amplifier had an idle timeout. To avoid
having to turn it on manually, I configured a raspberry pi
to send infrared signals which turned it on and set its input
channel when a device would want to stream music.

Whenever that Cambridge Amplifier was idle for 45 minutes, it automatically
shut itself off to save power. The main issue with this design is that the
amplifier could power two distinct zones. In the case of my parents, those
zones were the living room and the kitchen. This meant that, since the
amplifier itself was in the living room, whenever we wanted to stream music in
the kitchen, we had to:

1. Walk to the living room
2. Turn on the amplifier an set it's zone to only the kitchen
3. Pair the device that would stream music via bluetooth to it
4. Walk back to the kitchen

Doing this once or twice is fine, but having to do it daily quickly became tedious. So
I decided to see what I could do to automate it. Back then, I already had a raspberry
or 2 lying around so I took that as my starting point. The Cambridge came with a remote
so I figured I could use infrared signals to control it. after a bit of digging, I found
this precious little datasheet detailing the different IR codes which existed for the
model of amplifier my parents had:

{{< img src="cambridge-cxa60-ir-codes.png" alt="Cambridge CXA60 IR Datasheet" caption="" >}}

Another tool I discovered during my research was [shairport-sync][1]. It emulates
an airport express which allowed me to stream my music directly to it instead of walking
to the living room. Another great this this utility has are hooks. I could tell it to
execute a command whenever music got started or stopped. I figured if my music was streaming
through this, I could set a command to send IR signals whenever I started/stopped streaming
music. To do this, I needed to do two things:

- Make a small circuit for an infrared diode
- Figure out a way to correctly send the IR code to the diode via a script

Thankfully, hooking up a diode to a raspberry pi isn't all that hard. A transistor,
a resistance, and a couple of wires and you're good to go. When it came to sending the signal,
I discovered a beautiful little python package called [lirc][2] which can properly convert
numeric codes into impulses that can be sent to the raspberry pi's GPIO pins.

AND IT WORKED! All in all, this was quite a simple project. But getting to use it everyday,
I must say it did feel quite gratifying and fun!

[1]: https://github.com/mikebrady/shairport-sync
[2]: https://lirc.readthedocs.io/en/latest/
