---
title: "Guitar Hero"
date: 2023-10-23T23:18:05-04:00
mermaid: true
draft: false
---

One of my University classes tasked me with creating a custom remote as
well as a C++ GUI (using QT) that interfaces with it. I decided to create a *Guitar
Hero* clone compatible with the similar project *Clone Hero* file format.

The goal of this class was to teach Computer Science students about GUI design
as well as teach electrical engineers about PCB design. Both type of students
would also get to learn about software and hardware integration. Each team
was composed of 6 people of both engineering discipline. If you're wondering how
this project turned out, here's a little youtube playlist showcasing hardware
software and the integration between both that we achieved:

{{< youtubepl PLGcbRdKslprBkKg2NyGtS4AGuB2Ng_22e >}}

# Requirements

On the hardware side, the requirements were quite simple:

- The designed PCB needed to be less then or equal to 10x15cm
- A minimum of 5 switches were needed
- A joystick as well as an accelerometer had to get integrated
- We could choose wether to integrate a 5 segment or a bar graph display

After a little back and forth with our teachers, we came to an agreement that
we could configure some of our switches outside the pcb and mount them directly
to the guitar. This way, the pcb itself could be located at the base of a guitar
and host the strumming mechanism. We also convinced them it would be best for our
usecase to also mount the accelerometer on a guitar shaft and configure it as some
sort of trigger for a bonus streak.

On the software side of things, requirements were even simpler. All we
needed was to use the QT C++ library without any QML or QSS. It took very
little convincing to get my team on board with the *Guitar Hero* clone idea.

With those imposed constraints, we set ourselves a few targets of ourselves.

- Basic compatibility with songs create for [Clone Hero][1]
- Functional strumming mechanism
- Satisfying fret buttons
- Good input and visual latency

# File Parsing

*Clone Hero* is a popular game inspired by *Guitar Hero* where
players can download and play community developed songs. It uses
a games specific `.chart` file format to store data necessary
to play songs. Here is a small excerpt such a file:

```toml
[Song]
{
  Name = "Rock Is Too Heavy"
  Artist = "Owane"
  Charter = "GuitarZero132"
  Album = "Yeah Whatever"
  Year = ", 2018"
  Offset = 0
  Resolution = 192 # Only Mandatory
  Player2 = bass
  Difficulty = 6
  PreviewStart = 0
  PreviewEnd = 0
  Genre = "Jazz Fusion"
  MediaType = "cd"
  MusicStream = "song.ogg"
  GuitarStream = "drumbsdfklj.ogg"
}
[SyncTrack]
{
  0 = TS 4
  0 = B 161000
  1152 = B 162000
  1536 = B 160000
  21504 = TS 3
  22080 = TS 4
  ...
  75840 = TS 7 3
  76512 = TS 4
  84960 = TS 3
  85536 = TS 5
  86496 = TS 4
  89568 = TS 3
  90144 = TS 5
  91104 = TS 4
}
[ExpertSingle]
{
  1536 = N 2 0
  1536 = N 4 0
  1632 = N 2 256
  1632 = N 4 256
  1920 = N 2 0
  ...
  151008 = N 3 160
  151200 = N 2 0
  151296 = N 1 0
  151328 = N 0 128
  151488 = N 2 0
  151584 = N 0 0
  151680 = N 1 0
  151776 = N 3 256
  152064 = N 2 0
  152064 = N 5 0
  152112 = N 1 0
  152160 = N 0 0
  152352 = E soloend
}
```

This file contains a lot of information which didn't get implemented as the main
goal of the project was to have a functional prototype not a complete replica of
the game. Let's mainly focus here on the parts of the file specs which were required
to obtain a minimum viable product.

Most of the `[Song]` section is fairly explanatory but the **Resolution** field
merits some explanation. In music, songs have a pulse measured in BPMs (beats
per minute). For extra precision when it comes to the timing of individual
notes, *Clone Hero* decided to split each beat into smaller units called ticks.
The duration of a tick is determined by the resolution two things, the
resolution parameter stored in the song section, and the BPM of the song. Using
easy numbers, if a 60 BPM song (1 beat lasts 1 second) had a resolution of
1000, each tick would have a duration of 1 millisecond.

A more formal way of expressing this is as follows:

\\[
\begin{align}
T &= \frac{B^{-1}}{R}        \\\\
\mathrm{where}               \\\\
T&: \textrm{Tick resolution} \\\\
B&: \textrm{Current BPM}     \\\\
R&: \textrm{Tick resolution} \\\\
\end{align}
\\]

Something to note is that tick durations need to be calculated very precicely.
If a tick has a precision of $$\pm1$$ second, the timing is off by an entire
second after only a thousand ticks. To prevent this, every calculation made
when parsing the chartfile was done in nanoseconds. This way, even after a
million ticks, an unncertainty of $$\pm1$$ nanoseconds would only result in an
offset of a single milliseconds. Once every calculation was done, all note
values converted to milliseconds which play nicer with audio player libraries.

Up to now, this concept seems somewhat elegant. But the format gets much uglier
when you take into account that many songs accelerate, slow down and/or have
small non musical intermissions. So how can ticks remain reliable if the tempo
of a song isn't always the same? The file spec requires a list of `B`
parameters in the `[SyncTrack]` section. Here is one from the section above

```toml
  1152 = B 162000
```

What this states is that at the 1152th tick, the song now becomes 162.000 BPM.
There is no period in the format. It is implicit that the three last digits of
the BPM value are decimal points. From a practical standpoint, this means that
it's necessary to keep track of two things at each tick change:

- When did this event occur in the song (nanoseconds)
- What is the new tick duration value at that time (nanoseconds)

The final piece of the puzzle when parsing is then reading individual notes.
Each difficulty for a given instrument has it's own section. For the purpose of
our prototype, only lead guitar (referred to as `Single` in the file) sections
were parsed as it was the only piece of hardware we had developed. This leaves
us with the following sections to parse: `[ExpertSingle]`, `[HardSingle]`,
`[MediumSingle]`, & `[EasySingle]`.

Clone Hero allows some fancy behavior such as tapping notes without also
strumming. It also allows for strumming without pressing any notes. To keep
our prototype simple, we decided to limit what we parse to only notes that
require both strumming and hitting the notes. Such notes show up in the
following way in a chart file:

```toml
2208 = N 0 144
2496 = N 2 0
```

The first number here denotes the tick at which an event happens, the number
following the `N` indicates the concerned fret of the note (0-5), and the last
number indicates the duration of the note (0 means the note doesn't need to be
held). Next up, we'll look at how the code was structured to contain this info.

# Code Structure

As mentionned earlier, the project had to be written in C++ using the QT
library for visuals. We therefore need some sort of way to link visual objects
to notes parsed in the aforementionned `.chart` file. From least to most
specific, this is a simplified version of how we decided to store the
information:

{{<mermaid>}}
classDiagram
  direction RL

  class Song {
    -title : string
    -artist : string
    -album : string
    -year : string
    -charter : string
    +timestamps : TimeStamp[]
    +easy : Chord[]
    +medium : Chord[]
    +hard : Chord[]
    +expert : Chord[]
  }

  class Chord {
    +notes : *notes[5]
    -duration : int
    -start : int
    -end : int
    -rushStart : int
    -dragStart : int
    -rushRelease : int
    -dragRelease : int
    -spawnTime : int
    -noteNB : int
  }

  class TimeStamp {
    -time: long int
    -tick: int
    -nbpm: int
  }

  class QGraphicsRectItem {
  }

  class Note {
    -Fret : int
  }

  QGraphicsRectItem --|> Note
  Note "1..5" o-- Chord
  Chord o-- Song
  TimeStamp o-- Song
{{</mermaid>}}

The timestamp list in a song is only used as a tool to then parse different
difficulties. Once all difficulties have been parsed, it is no longer needed.

As you might see, a given difficulty doesn't contain a list of notes but a list
of chords instead. The reason behind this choice is that many notes are meant
to be played together (as a chord). This means that all those notes have the
same start and duration. You can therefore save memory by grouping notes
together. Afterwards, a single note can be thought of as a single note chord.
Another benefit to this approach is that QT offers the option to animate
objects in parallel. This means that a single animation call can be made to the
QT engine for every chord, and we're sure that all notes appear in sync on
screen while playing.

# GUI Design

# PCB and Guitar Design

# Communication layer

<!-- Integration   https://youtu.be/FKOd6nEcEC8 -->
<!-- Song          https://youtu.be/G2GX4o7dhNY -->
<!-- Accelerometer https://youtu.be/xl-ZMSSMalw -->
<!-- Bar Graph     https://youtu.be/WZeAdRM9tGo -->
<!-- Strumming     https://youtu.be/TxubEPih7yw -->
<!-- Joystick      https://youtu.be/q-Qc5jLBBzU -->
<!-- Demo1         https://youtu.be/c_Gxq5UKYd4 -->
<!-- Demo2         https://youtu.be/69InfsTlqqA -->


[1]: https://clonehero.net/

1. Parse generic info from the `[Song]` section
2. Generate a timestamp table noting when ticks change duration (and to what value)
3. Read the file line by line until a supported difficulty header is encountered
4. Parse all notes using the timestamp table to know their specific time
5. Merge notes with identical start/end time into chords
6. Convert all time values from nanoseconds to milliseconds
