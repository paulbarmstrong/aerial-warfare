# Arma 3 Game-mode: CTI Airborne

## Details

* Author: Paul Armstrong
* Date: November 2017 (As of March 2018 I am still working on this project)
* Progress: ~70%

## Demonstration

![animated gif](https://i.imgur.com/KqzUq9k.gif)

## Description

Airborne is a game-mode for Arma 3 I've been working on for a few months now. The premise of the game-mode is that all players are pilots of helicopters and airplanes. Players must communicate and play as a team in order to complete objectives.

The arma engine's SQF language is very old and quirky, so that is why some of the code might look inefficient or unnecessary (For example, the SQF language does not feature implicit short circuit evaluation).

## Usage

To use this game-mode you will have to place the cti-airborne folder into *Documents/Arma 3 - Other Profiles/[Username]/MPMissions*. However, I would recommend waiting until I finish the project and submit it to the steam workshop.

If you just want to take a look at the code feel free.

## Why

Arma 3 is one of my favorite games and flying aircraft is one of my favorite parts of the game, but I feel like there aren't any solid aircraft-centric game-modes.

A recent update to Arma 3 prompted the devs to refine the aircraft systems and add significantly more aircraft-centric API. The update is what brought my CTI airborne project into the realm of possibility.

By now I have a good understanding of the SQF language and what is and isn't possible with the current arma 3 API. I think that with the game in its current state, I shouldn't run into any more major barriers while finishing this project.

## Plans

* Create a script to allow any airplane to perform a tailhook landing on the carrier
* Create versions for takistan and chernarus and use hard links to link all scripts

## Bugs

* There is some something causing the log to be spammed with message about destroy and it has something to do with playableAI behavior
* Sometimes LZ gets cleared, shows 0/4, white, no men there, but cannot be captured (caused by network latency?)