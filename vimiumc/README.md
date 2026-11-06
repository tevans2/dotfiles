# Vimium C browser workflow

This config is tuned for a minimal Helium setup that keeps Arc-like keyboard speed without rebuilding Arc inside the browser.

## Key mappings

| Key | Action | Why |
| --- | --- | --- |
| `<c-o>` / `<c-o:i>` | Previous visited tab | Quick back-and-forth between two active tabs, including focused text inputs. |
| `<c-t>` / `<c-t:i>` | Open Vimium C vomnibar in a new tab | Arc-like command/new-tab flow, including inside focused text inputs. |
| `<c-p>` / `<c-p:i>` | Search open tabs | Lightweight replacement for Arc-style tab search, including inside focused text inputs. |
| `<c-s-j>` | Move current tab right | Keyboard tab organization. |
| `<c-s-k>` | Move current tab left | Keyboard tab organization. |
| `<c-x>j` | Close tabs on the right | Deliberate destructive action behind a prefix. |
| `<c-x>k` | Close tabs on the left | Deliberate destructive action behind a prefix. |
| `<c-x>o` | Close other tabs | Clean the current working set. |
| `<c-x>p` | Pin/unpin current tab | Promote/demote daily anchor tabs. |

`<c-j>` and `<c-k>` are intentionally unmapped here: the Hopper extension owns them (next/previous tab in the current space).
Vimium C cancels those keys on web pages before extension shortcuts run, so they must stay free of mappings.

Plain `J` and `K` are unmapped to avoid accidental tab switching while reading or using web apps.

`<c-i>` is intentionally unmapped. Vimium C exposes `visitPreviousTab`, but not a true recency-forward command that inverts `<c-o>` like Vim's jumplist. Mapping `<c-i>` to `nextTab` was misleading, so the config leaves it alone.

## Search engines

The search engine list is intentionally small. Use Helium `!bangs` for long-tail searches, and keep Vimium C focused on daily destinations:

- Google
- DuckDuckGo
- Brave Search
- GitHub
- YouTube
- Wikipedia
- Google Maps
- Google Scholar
- Linear (`lin` / `linear`)
- MDN
- npm
- docs.rs

## Exclusion rules

The config passes common conflicting keys through to app-like websites:

- Google Docs
- Figma
- Notion
- Linear (`/`, `j`, and `k` only; Vimium keeps `<c-j>`, `<c-k>`, `<c-t>`, and `<c-p>` for tab workflow)
- github.dev
- vscode.dev
- Discord
- Telegram Web

These rules preserve browser-wide Vimium behavior while letting editing/productivity apps keep their own shortcuts. If a site still feels broken, add only the specific conflicting key instead of disabling Vimium globally.

## Profile separation

`vimSync` is disabled. For Work / Uni / Personal browser profiles, import this same config manually into each profile so profile separation remains explicit and predictable.
