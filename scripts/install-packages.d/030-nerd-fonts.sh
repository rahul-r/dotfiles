# shellcheck shell=bash
# Install pinned Nerd Font families into the per-user font directory.

# Nerd Fonts are not in the distribution repositories. Each family is pinned to
# this release so the download can be checksum-verified; to add another, extend
# the array, its SHA-256 from the release's SHA-256.txt, and nerd_font_family.
NERD_FONT_VERSION=v3.5.1
NERD_FONTS=(UbuntuMono DroidSansMono)
NERD_FONT_UBUNTUMONO_SHA256=e5eee9529ee538cf30cab268abc4e877e0a57142d10fbf170f715c4636a336d1
NERD_FONT_DROIDSANSMONO_SHA256=e11ef953e84bfb85f9628383f4512675b0604c95d346b10c4d6f481dd47649cf

# Return the pinned checksum for a font name, or fail if none is configured.
# A case keeps this working with the bash 3.2 that ships with macOS.
nerd_font_sha256() {
  case "$1" in
    UbuntuMono) printf '%s' "$NERD_FONT_UBUNTUMONO_SHA256" ;;
    DroidSansMono) printf '%s' "$NERD_FONT_DROIDSANSMONO_SHA256" ;;
    *) return 1 ;;
  esac
}

# Map an archive name to the family fontconfig reports. The two differ: upstream
# truncates the patched DroidSansMono family to "DroidSansM Nerd Font", so the
# installed name cannot be derived mechanically as "<archive> Nerd Font".
nerd_font_family() {
  case "$1" in
    UbuntuMono) printf '%s' "UbuntuMono Nerd Font" ;;
    DroidSansMono) printf '%s' "DroidSansM Nerd Font" ;;
    *) return 1 ;;
  esac
}

# A font is present when fontconfig lists its family. Without fc-list, fall
# back to a font file already sitting in the per-font directory; the archives
# use .ttf (UbuntuMono) or .otf (DroidSansMono).
nerd_font_available() {
  local target_dir=$1 family=$2 installed
  if command -v fc-list >/dev/null 2>&1; then
    installed=$(fc-list 2>/dev/null) || installed=""
    grep -qiF -- "$family" <<< "$installed"
  else
    compgen -G "$target_dir/*.ttf" >/dev/null 2>&1 ||
      compgen -G "$target_dir/*.otf" >/dev/null 2>&1
  fi
}

# Nerd Fonts publish ready-made archives per family. Install pinned versions
# into the per-user font directory (no sudo) and refresh the font cache. A
# failure is recorded in FAILURES so the remaining fonts and steps still run.
# macOS gets both families from BREW_CASKS, so there is nothing to do there.
install_nerd_fonts() {
  local font family font_dir url expected tmp zip actual checksum_cmd
  if [[ "$PLATFORM" == "Darwin" ]]; then
    return 0
  fi

  font_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
  if command -v sha256sum >/dev/null 2>&1; then
    checksum_cmd=sha256sum
  else
    checksum_cmd="shasum -a 256"
  fi

  for font in "${NERD_FONTS[@]}"; do
    if ! family=$(nerd_font_family "$font"); then
      echo "error: no installed family name for $font; add it to nerd_font_family" >&2
      FAILURES+=("$font")
      continue
    fi
    url="https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONT_VERSION/$font.zip"

    if nerd_font_available "$font_dir/$font" "$family"; then
      echo "already installed: $family"
      continue
    fi

    if ! expected=$(nerd_font_sha256 "$font"); then
      echo "error: no pinned SHA-256 for $font; add its checksum to nerd_font_sha256" >&2
      FAILURES+=("$font")
      continue
    fi

    if [[ $DRY_RUN -eq 1 ]]; then
      announce_step "curl -fsSL -o <tmp>/$font.zip $url"
      announce_step "$checksum_cmd <tmp>/$font.zip (expect $expected)"
      announce_step "unzip -o -q <tmp>/$font.zip -d $font_dir/$font"
      announce_step "fc-cache -f $font_dir"
      continue
    fi

    if ! command -v unzip >/dev/null 2>&1; then
      echo "error: unzip is required to install $family" >&2
      FAILURES+=("$font")
      continue
    fi
    if ! command -v fc-cache >/dev/null 2>&1; then
      echo "error: fc-cache from fontconfig is required to install $family" >&2
      FAILURES+=("$font")
      continue
    fi

    if ! mkdir -p "$font_dir"; then
      echo "error: could not create $font_dir" >&2
      FAILURES+=("$font")
      continue
    fi
    if ! tmp=$(mktemp -d); then
      echo "error: could not create a temporary directory for $family" >&2
      FAILURES+=("$font")
      continue
    fi
    zip="$tmp/$font.zip"

    announce_step "curl -fsSL -o $zip $url"
    if ! curl -fsSL -o "$zip" "$url"; then
      echo "error: could not download $url" >&2
      rm -rf "$tmp"
      FAILURES+=("$font")
      continue
    fi

    if ! actual=$(sha256_of "$zip"); then
      echo "error: could not checksum $font.zip" >&2
      rm -rf "$tmp"
      FAILURES+=("$font")
      continue
    fi
    if [[ "$actual" != "$expected" ]]; then
      echo "error: checksum mismatch for $family: expected $expected, got $actual" >&2
      rm -rf "$tmp"
      FAILURES+=("$font")
      continue
    fi

    announce_step "unzip -o -q $zip -d $font_dir/$font"
    if ! unzip -o -q "$zip" -d "$font_dir/$font"; then
      echo "error: could not unpack $family into $font_dir/$font" >&2
      rm -rf "$tmp"
      FAILURES+=("$font")
      continue
    fi

    announce_step "fc-cache -f $font_dir"
    if ! fc-cache -f "$font_dir"; then
      echo "error: fc-cache failed for $font_dir" >&2
      rm -rf "$tmp"
      FAILURES+=("$font")
      continue
    fi

    rm -rf "$tmp"
    echo "installed: $family"
  done
}
