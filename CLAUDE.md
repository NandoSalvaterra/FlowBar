# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

Open `FlowBar.xcodeproj` in Xcode and use Cmd+R to run. There are no tests and no CLI build scripts.

Command-line build (optional):
```bash
xcodebuild -project FlowBar.xcodeproj -scheme FlowBar -configuration Debug build
```

## Project Overview

FlowBar is a SwiftUI dictation/recording bar UI, targeting iOS, iPadOS, macOS, and visionOS (deployment target 26.2). Bundle ID: `com.salvaterratech.FlowBar`.

## Architecture

All UI lives in [FlowBar/FlowBarView.swift](FlowBar/FlowBarView.swift). The app entry point is [FlowBar/FlowBarApp.swift](FlowBar/FlowBarApp.swift).

### State Machine (`FlowBarState`)

```
collapsed → expanded → expandedWithTooptip (typo in source, keep as-is)
                ↓
            recording
```

- `collapsed`: shows a small pill (`CollapsedBar`). Tap to expand.
- `expanded`: shows `ExpandedBar` without recording controls. After 1 second, transitions to `expandedWithTooptip`.
- `expandedWithTooptip`: shows `TooltipView` above `ExpandedBar` prompting the user to click.
- `recording`: `ExpandedBar` with cancel/stop buttons visible.

### Key Swift settings
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` — all types are implicitly `@MainActor`.
- `SWIFT_APPROACHABLE_CONCURRENCY = YES` — Swift 6 structured concurrency.
- Colors are defined in `FlowBar/Colors.xcassets` and referenced via `Color(.colorName)`.
- Image assets (`close`, `stop`) are PDFs in `FlowBar/Assets.xcassets` and referenced via `Image(.assetName)` using generated Swift symbols (`ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES`).
