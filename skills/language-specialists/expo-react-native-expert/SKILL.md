---
name: expo-react-native-expert
description: Use when building mobile applications with Expo and React Native that require native module integration, navigation setup, performant animations, push notifications, OTA updates, or App Store/Play Store deployment.
codex-short-description: "Mobile applications with Expo and React Native that require native module integration…"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
related-skills:
  - codebase-explain
  - codebase-plan-refactor
loop-eligible: false
compatibility: claude-code codex opencode
---

# Expo / React Native Expert

You build React Native applications with Expo. The framework question that governs everything is
what runs on the JS thread versus the native side.

## Match the codebase first

Read the existing configuration, conventions, and dependency choices before applying anything below. Introducing a second idiom into a consistent codebase costs more than it returns; where the existing approach genuinely blocks the work, raise it as its own change rather than resolving it inside an unrelated ticket.

## Keep the JS thread free

Animations, gestures, and list scrolling stutter when the JavaScript thread is busy. Use
Reanimated worklets and the native driver so animation runs off the JS thread, and move heavy
computation off the render path. Dropped frames are almost always this.

## Lists are where performance dies

`FlatList` or `FlashList` with stable `keyExtractor`, `getItemLayout` where item height is
known, and memoized row components. A `ScrollView` containing a mapped array renders every item
— fine for ten, fatal for a thousand.

## Know which Expo workflow you are in

Managed with config plugins covers most needs and keeps builds simple. A native module without
a plugin means prebuild or a development build — decide this deliberately, because moving later
is disruptive. Expo Go is a development convenience, not a test of the shipped app; anything
using custom native code must be tested in a development or production build.

## Platform differences are not incidental

Safe areas, keyboard behavior, back navigation, permission flows, and status bar handling all
differ. Test on both real platforms — the simulator hides permission and performance realities.

## Updates and the store boundary

OTA updates via EAS ship JavaScript changes; native changes require a store build. Know which
your change is, and keep an update rollback path. Shipping a broken OTA update to everyone at
once is avoidable with staged rollout.

## Storage, secrets, and offline

Nothing sensitive in AsyncStorage — use secure storage. Assume the network is unreliable: define
the offline behavior and the retry policy rather than letting requests fail silently into a
spinner.

## Reporting

State the workflow (managed, prebuild, bare), what runs on which thread, the list virtualization,
the platforms tested, and the update path for this change.

> **Host portability:** tool names in this skill follow Claude Code conventions; on other hosts (Codex, opencode) map them by intent — see [PORTABILITY.md](../../PORTABILITY.md).

<!-- self-evolve:start -->

## Self-Evolve Loop

Journal: `~/.ink-and-agency/learnings/expo-react-native-expert.md` (workspace-local
`.ink-and-agency/learnings/expo-react-native-expert.md` where the sandbox confines writes). Read it
first, append what the run taught last — [SELF-EVOLVE.md](../../SELF-EVOLVE.md).

<!-- self-evolve:end -->
