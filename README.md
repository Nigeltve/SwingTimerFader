# SwingTimerFader

A World of Warcraft **Forever** addon that fades the game's built-in swing timer bars while they aren't in use.

- **Melee bars** (main hand + off hand) are shown while you're auto-attacking in melee.
- **Ranged bar** is shown while Auto Shot, a wand (Shoot) or Throw is repeating.
- Each group fades on its own: while you melee, the ranged bar stays faded, and vice versa.
- Bars appear **instantly** when you start attacking and fade out **smoothly** after you stop.

The addon only changes the bars' transparency. It doesn't move, resize or replace them, and Blizzard's own behaviour (such as the range dimming) is left alone.

## Requirements

- WoW Forever client (Interface `16001`)
- The built-in swing timer turned on in the game's options

## Installation

1. Download the latest `SwingTimerFader-vX.Y.Z.zip` from the [Releases](../../releases) page.
2. Extract it into `World of Warcraft\_forever_\Interface\AddOns\`, so you end up with `AddOns\SwingTimerFader\SwingTimerFader.toc`.
3. Restart the game or `/reload`.

## Settings

Open **Settings → AddOns → SwingTimerFader**, or type `/stf`.

| Setting | Default | Range | Saved |
|---|---|---|---|
| Enabled | On | – | Per character |
| Fade delay (wait after attacking stops) | 1.5s | 0–5s | Account-wide |
| Fade-out time | 0.5s | 0–3s | Account-wide |

## Slash commands

| Command | What it does |
|---|---|
| `/stf` or `/stf config` | Open the options panel |
| `/stf toggle` | Turn the addon on/off for this character |
| `/stf delay <seconds>` | Set the fade delay |
| `/stf fade <seconds>` | Set the fade-out time |
| `/stf status` | Print the current state and whether each swing bar was found |

## Compatibility

Other addons that also fade the built-in swing timer (for example FadeAnything's swing timer entries) will fight with this one. Turn those entries off.

## Troubleshooting

- **Bars never fade:** run `/stf status`. Each bar should show `=ok`. If one shows `missing`, the game's frame name may have changed; please open an issue with the output.
- **Lua errors:** enable them with `/console scriptErrors 1`, `/reload`, and include the error text in an issue.

## Releasing (maintainers)

Releases are built by GitHub Actions: **Actions → Create Release → Run workflow**, enter a version like `1.0.0`. The workflow stamps the version into the `.toc`, zips the addon and publishes a GitHub release with notes.

## Author

NuggyNige
