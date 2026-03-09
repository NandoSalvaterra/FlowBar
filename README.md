# FlowBar

A SwiftUI dictation/recording bar UI for iOS, iPadOS, macOS, and visionOS.

## Requirements

- Xcode 16+
- Deployment target: 26.2

## Getting Started

Open `FlowBar.xcodeproj` in Xcode and press `Cmd+R` to run.

## Architecture

All UI lives in `FlowBar/FlowBarView.swift`. The app entry point is `FlowBar/FlowBarApp.swift`.

### State Machine

```
collapsed → expanded → expandedWithTooltip
                ↓
            recording
```

- **collapsed** — small pill. Tap to expand.
- **expanded** — shows the bar without recording controls. After 1 second, transitions to `expandedWithTooltip`.
- **expandedWithTooltip** — shows a tooltip above the bar prompting the user to click.
- **recording** — bar with cancel and stop buttons, animated waveform active.
