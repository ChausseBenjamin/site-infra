---
title: Encryption in Python
author: Benjamin Chausse
date: 2023-10-25T20:01:27-04:00
draft: true
---

During my last year of highschool, I designed my very own text encryption
algorithm. I wrote software in python to encode and decode text using a
custom algorithm I made solely to better understand information theory.

The class in which I did this project was designed to teach students about
managing long term endeavours. People could tackle projects related to just
about anything. One person wrote and printed a recipe books, another built a
small soap box cart, someone even built a potato canon. When it came my turn to
choose, I decided to do something related to programming where I could learn
things a bit more abstract along the way.

During the research phase of this endeavour, I learned about classic
cryptography stories such as the ceasar cypher, enigma, symetric and asymetric
key exchanges. Realizing that some encryption methods could be broken through
easy non-bruteforce approaches intrigued me. I therefore settled to attempt a
message encoding method which would be more secure than something such as a
ceasar cypher. I wanted to build my own algorithm and this is what I came up
with:

My initial realization was the reality that information can be represented
through a variety of methods. An image can be stored as one huge integer in
binary form. Text, encoded in ASCII, was just a list of 255 symbols. When
viewed from that perspective, an entire article could be thought of as one big
integer in base255. I decided to start by converting the source message one
might want to encrypt into decimal form as shown by this animation:

{{< img src="msg-encode.gif" alt="How the message gets encoded" caption="" >}}

The thing is, if a message can be converted from base255 to decimal, so can
the password protecting the original message. You would then have both the message
and the password in a format that feels much more intuitive to manipulate.
So this is what I did:

{{< img src="psswd-encode.gif" alt="How the password gets encoded" >}}
