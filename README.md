# StromX Code Studio

An Android-first mobile coding workspace inspired by Termux.

## Current MVP
- Flutter Material 3 dark interface
- Code editor buffer with save-to-app-workspace
- Android sandbox shell command runner using `/system/bin/sh`
- Terminal output and command history in the current session
- GitHub Actions workflow to build a signed-by-Android-build-tools release APK artifact

## Important runtime boundary
This MVP is **not a full Linux distribution**. Android's app sandbox shell is not equivalent to Termux's package-managed environment. It cannot install arbitrary Linux packages or expose unrestricted device files. A future full Linux environment requires a separately integrated and maintained proot/rootfs runtime.

## Build APK
1. Push to the `main` branch, or open GitHub Actions.
2. Run **Build StromX Android APK** using **Run workflow**.
3. Download the `stromx-code-studio-release` artifact from the completed workflow.

The workflow generates the standard Android Gradle project, runs Flutter analysis, builds a release APK, and uploads it as a workflow artifact.

## Next milestones
- Persistent multi-file project explorer
- Syntax highlighting and language-aware editing
- Git integration
- Isolated Python/Node toolchains
- Remote build service for user projects
- Strom AI API integration with user-provided credentials
