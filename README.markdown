# Harvest

## Running tests

To override the default interface for Cucumber tests, use the `HARVEST_INTERFACE` environment variable, e.g.:

    HARVEST_INTERFACE=http cucumber
    HARVEST_INTERFACE=http guard

## Development server

To start a webserver for interactive testing, open `pry` and run:

    start_server

## Repository notes

The repository contains rake tasks to convert (roughly) darcs patches into git commits, to push to [Startups Manchester][startman]. You must unsure *_darcs/prefs/defaults* is configured to run them!

[startman]: http://startupsmanchester.com/