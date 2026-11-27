#!/usr/bin/env bash
set -euo pipefail
if ! command -v flutter >/dev/null 2>&1 && [ ! -x "$HOME/flutter/bin/flutter" ]; then
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$HOME/flutter"
fi
export PATH="$HOME/flutter/bin:$PATH"
flutter --version
flutter precache --web
flutter create --platforms=web --project-name maziwa_vault .
