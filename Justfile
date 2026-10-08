uuid := "unite@hardpixel.eu"
src  := justfile_directory() / uuid
dest := env("XDG_DATA_HOME", env("HOME") / ".local/share") / "gnome-shell/extensions" / uuid

default:
    @just --list

# Compile the GSettings schemas
schemas:
    glib-compile-schemas "{{src}}/schemas"

# Symlink the extension into the user extensions dir and enable it
install: schemas
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -e "{{dest}}" ] && [ ! -L "{{dest}}" ]; then
        echo "error: {{dest}} exists and is not a symlink; remove it first" >&2
        exit 1
    fi
    mkdir -p "$(dirname "{{dest}}")"
    ln -sfn "{{src}}" "{{dest}}"
    echo "linked {{dest}} -> {{src}}"
    gnome-extensions enable "{{uuid}}" || echo "note: log out and back in so GNOME Shell picks up the extension, then run 'just enable'"

# Disable the extension and remove the symlink
uninstall:
    -gnome-extensions disable "{{uuid}}"
    rm -f "{{dest}}"

enable:
    gnome-extensions enable "{{uuid}}"

disable:
    gnome-extensions disable "{{uuid}}"

# Show extension state
status:
    gnome-extensions info "{{uuid}}"

# Follow GNOME Shell logs
logs:
    journalctl -f -o cat /usr/bin/gnome-shell
