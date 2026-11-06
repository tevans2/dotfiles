# tmux plugin patches

Local changes to plugins under `plugins/`. TPM updates (`prefix + U`) overwrite
plugin checkouts, so anything here has to be reapplied afterwards.

## agent-sidebar-jk-stay-in-list.patch

`tmux-agent-sidebar` v0.10.1 (commit b56a47a). Upstream lets `j`/`k` fall out of
the agent list: `j` at the bottom hands focus to the activity log and `k` at the
top hands it to the filter row. The patch keeps `j`/`k` inside the agent list and
leaves that traversal on the arrow keys, so the bottom panel is still reachable.

Reapply after a plugin update:

    cd ~/.config/tmux/plugins/tmux-agent-sidebar
    git apply ~/.config/tmux/patches/agent-sidebar-jk-stay-in-list.patch
    cargo build --release
    rm -f bin/tmux-agent-sidebar                      # fresh inode: macOS SIGKILLs
    cp target/release/tmux-agent-sidebar bin/         # a binary overwritten in place
    codesign --force -s - bin/tmux-agent-sidebar

The rebuilt binary keeps the upstream version string, so the plugin's install
wizard treats it as current and will not re-download over it.
