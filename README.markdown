# Harvest

To override the default interface for Cucumber tests, use the `HARVEST_INTERFACE` environment variable, e.g.:

    HARVEST_INTERFACE=http cucumber
    HARVEST_INTERFACE=http guard

To start a webserver for interactive testing, open `pry` and run:

    start_server