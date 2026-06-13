# Caffine

A macOS menu bar app that prevents your display from sleeping.

## Features

- Lives in the menu bar, no Dock icon
- Toggle sleep prevention on/off
- Optional countdown timer: 15 min, 30 min, 1 hr, 2 hrs, 5 hrs, or indefinitely
- Remaining time shown next to the menu bar icon
- Launch at Login support

## Requirements

- macOS 13.0+
- Xcode 15+

## Getting Started

1. Clone the repo and open `Caffine.xcodeproj` in Xcode
2. Set your Development Team under **Signing & Capabilities**
3. Run

## How it works

Uses an `IOPMAssertion` (`PreventUserIdleDisplaySleep`) to tell macOS not to sleep the display. The assertion is released when Caffine is toggled off, when a timer expires, or when the app quits.

You can verify it's active from Terminal:

```sh
pmset -g assertions
```
