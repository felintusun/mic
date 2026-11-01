# mic's everyday commands: `just` lists them. `just ci` runs what CI's check, site and deny jobs
# run, on this platform; the box is `cargo testbox` (testbox/README.md), here `just box`.

set shell := ["bash", "-euo", "pipefail", "-c"]
set positional-arguments

# Lists the recipes.
default:
    @just --list

# The window, against a relay: `just run --relay https://relay.example/`, or MIC_RELAY.
run *args:
    cargo run -p mic-slint -- "$@"

# The window's release build, into target/release/mic.
build:
    cargo build --release --locked -p mic-slint

# What CI checks, on this platform alone and without the box's tooling (`just view`).
ci: fmt-check clippy test js deny

# Formats the Rust and the JavaScript.
fmt:
    cargo fmt --all
    deno fmt

# The formats, checked, as CI does: the JavaScript's in `js`.
fmt-check:
    cargo fmt --all -- --check

# As CI: every target and feature, a warning fails.
clippy:
    cargo clippy --workspace --all-targets --all-features --locked -- -D warnings

# The workspace's tests; arguments go to cargo test, such as a filter.
test *args:
    cargo test --workspace --all-features --locked "$@"

# Beyond `test`, as CI: the system keyring's tests (one unlocked) and the GPU's (lavapipe will do).
test-all *args:
    MIC_TEST_KEYRING=1 MIC_TEST_GPU=1 cargo test --workspace --all-features --locked "$@"

# The JavaScript: Deno's lint and format check (deno.jsonc), the site's tests under Node.
js:
    deno lint
    deno fmt --check
    node --test site/*.test.mjs

# The site as GitHub Pages serves it, into target/site.
site:
    site/build.sh target/site
    @echo "target/site: python3 -m http.server -d target/site"

# Licenses, advisories and sources (deny.toml); needs cargo-deny.
deny:
    cargo deny --locked check

# The box's display tooling, a workspace of its own (Linux only), as CI checks it.
view:
    cd testbox/view && cargo fmt --all -- --check
    cd testbox/view && cargo clippy --workspace --all-targets --locked -- -D warnings
    cd testbox/view && cargo test --workspace --locked

# The test box: `just box up`, `just box run`, `just box dev <phase>`.
box *args:
    cargo testbox "$@"
