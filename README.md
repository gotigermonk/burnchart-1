#[burnchart](http://radekstepan.com/burnchart)

GitHub Burndown Chart as a Service. Answers the question "are my projects on track"?

[![Build Status](https://travis-ci.org/unfoldingWord-dev/burnchart.svg)](https://travis-ci.org/unfoldingWord-dev/burnchart)

##Features

1. Running from the **browser**, apart from GitHub account sign in which uses Firebase backend.
1. **Private repos**; sign in with your GitHub account.
1. **Store** projects in browser's `localStorage`.
1. **Off days**; specify which days of the week to leave out from ideal burndown progression line.
1. **Trend line**; to see if you can make it to the deadline at this pace.
1. Different **point counting** strategies; select from 1 issues = 1 point or read size from issue label.

##Quick Start

```bash
$ npm install burnchart -g
$ burnchart 8080
# burnchart/2.0.8 started on http://0.0.0.0:8080
```

##Configuration

At the moment, there is no ui exposed to change the app settings. You have to edit the `src/models/config.coffee` file.

An array of days when we are not working where Monday = 1. The ideal progression line won't *drop* on these days.

```coffeescript
"off_days": [ ]
```

Choose from `ONE_SIZE` which means each issue is worth 1 point or `LABELS` where issue labels determine its size.

```coffeescript
"points": "ONE_SIZE"
```

If you specify `LABELS` above, this is the place to set a regex used to parse a label and extract points size from it. When multiple matching size labels exist, their sum is taken.

```coffeescript
"size_label": /^size (\d+)$/
```

##Commands

Read the [Architecture](docs/ARCHITECTURE.md) document when contributing code.

```bash
rake build                  # Build everything & minify
rake build:css              # Build the styles with LESS
rake build:js               # Build the app with Browserify
rake build:minify           # Minify build for production
rake commit[message]        # Build app and make a commit with latest changes
rake install                # Install dependencies with NPM
rake publish                # Publish to GitHub Pages
rake serve                  # Start a web server on port 8080
rake test                   # Run tests with mocha
rake test:coverage          # Run code coverage, mocha with Blanket.js
rake test:coveralls[token]  # Run code coverage and publish to Coveralls
rake watch                  # Watch everything
rake watch:css              # Watch the styles
rake watch:js               # Watch the app
```
