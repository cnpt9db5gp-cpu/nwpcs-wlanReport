# nwpcs-wlanReport

Linux equivalent of `netsh wlan show networks` + `netsh wlanreport`.

Scan nearby Wi-Fi networks and generate a single-file HTML report you can
open in any browser (`file://` — no server needed), or serve over HTTP.
Ships with an ASCII-art banner, chat-style progress log, and an interactive
chatbox mode. Use `--no-banner` / `--no-color` for calm, script-friendly output.

## Requirements

- Linux with NetworkManager (`nmcli`), `iw`, `ip` (+ optional `ping`, `journalctl`, `lspci`)
- Python 3.9+ (stdlib only — no dependencies)
- A Wi-Fi adapter with driver loaded. Missing/optional pieces degrade gracefully;
  run `nwpcs-wlandiag check-deps` first — it tells you exactly what's absent and how
  to install it on your distro (Arch/Debian/Fedora families).

## Install

One-liner (installs to `~/.local/bin`, then runs the dependency check):

```bash
curl -fsSL https://raw.githubusercontent.com/cnpt9db5gp-cpu/nwpcs-wlanReport/main/install.sh | bash
```

Or manually:

```bash
git clone https://github.com/cnpt9db5gp-cpu/nwpcs-wlanReport.git
cd nwpcs-wlanReport
install -m755 nwpcs-wlandiag ~/.local/bin/nwpcs-wlandiag
nwpcs-wlandiag check-deps
```

> The event-log section needs journal read access. If `check-deps` reports the
> journal as LIMITED, run `sudo usermod -aG systemd-journal $USER`, re-login,
> and re-run. Everything else keeps working without it.

## Usage

Just type `nwpcs-wlandiag` with no arguments — it stays inside the interactive
mode until you type `exit`, so you only ever type short commands (`scan`,
`report`, `open`):

```
$ nwpcs-wlandiag
you> scan
you> report
you> open
you> exit
```

Or run one-shot commands from your shell:

```bash
nwpcs-wlandiag check-deps                     # verify tools + permissions first
nwpcs-wlandiag check-deps --json              # machine-readable readiness
nwpcs-wlandiag scan                          # terminal table (like netsh wlan show networks)
nwpcs-wlandiag scan --json --limit 10 --sort signal|channel|ssid
nwpcs-wlandiag info                          # current connection + best channels + security summary
nwpcs-wlandiag speed                          # real download throughput in Mbps
nwpcs-wlandiag history                        # signal/link snapshots over time
nwpcs-wlandiag chat                          # interactive chatbox mode
nwpcs-wlandiag report                        # -> data dir (see below) + -data.json + -chat.log
nwpcs-wlandiag report -o /tmp/wifi.html --open
nwpcs-wlandiag open                            # open the latest report in your browser
nwpcs-wlandiag report --serve --port 8000    # generate + serve + open browser
nwpcs-wlandiag serve ~/.local/share/nwpcs-wlandiag/nwpcs-wlandiag.html --port 8000 --open
nwpcs-wlandiag --iface wlo1 report -o out.html
nwpcs-wlandiag --no-banner scan              # skip the ASCII banner
```

### Chat mode

```
$ nwpcs-wlandiag chat
you> scan
you> report -o /tmp/wifi.html
you> open
you> exit
```

Commands: `check | scan | info | advise | speed | history | report [-o file] | open | serve [port] | log | clear | help | exit`.
The transcript is saved inside the data dir (see below).

### Bigger diagnostics

- **History** — every `scan`/`info`/`report` appends to `history.db` in the
  data dir (30-day retention, `--no-history` opts out). The report charts
  per-SSID signal over 7 days plus recent link snapshots.
- **Channel advisor** — scores channels by neighbor congestion (with 2.4 GHz
  overlap math) and names the best pick per band, in `info`, chat (`advise`),
  and the report.
- **Speed test** — real HTTP download throughput in Mbps. Runs in `report`
  (skip with `--no-speed`), on demand via `nwpcs-wlandiag speed [--bytes N]`.
- **Security audit** — flags open/WEP/WPA1-TKIP networks and mixed-security
  same-SSID groups (evil-twin suspects), plus a verdict on your own link.

### Where files go

Nothing is scattered across `$HOME`. Everything the tool writes lives in one
organized directory (XDG-aware — honors `$XDG_DATA_HOME`):

```
~/.local/share/nwpcs-wlandiag/
├── nwpcs-wlandiag.html       # latest report (open with `nwpcs-wlandiag open`)
├── nwpcs-wlandiag-data.json  # raw scan data
├── nwpcs-wlandiag-chat.log   # chat transcripts
└── history.db                # signal/link history (sqlite)
```

Pass `-o` anywhere else if you want a report in a specific place — sidecars
(`-data.json`, `-chat.log`) are written next to it.

### Sharing reports

The HTML embeds nearby SSIDs/BSSIDs plus your local IP and MAC. Fine for
personal use — think twice before posting a raw report publicly.

## Report contents

Summary KPIs, recommendations (congestion, weak WPA1/TKIP, band advice),
adapter details, current connection + `iw link`/`station` dumps, sortable and
filterable network table, channel utilization + signal ranking charts,
band/security breakdown, ping/DNS/route diagnostics, NetworkManager event log,
and the exact collection commands (Windows parity table included).

## Windows parity

| Windows                          | This tool              |
|----------------------------------|------------------------|
| `netsh wlan show networks mode=bssid` | `nwpcs-wlandiag scan` |
| `netsh wlanreport`               | `nwpcs-wlandiag report --open` |

## Layout

```
nwpcs-wlanReport/
├── nwpcs-wlandiag   # the CLI (single-file, executable, stdlib-only)
├── install.sh    # one-line installer (curl … | bash)
├── README.md
├── LICENSE
└── .gitignore
```

Generated artifacts (`nwpcs-wlandiag.html`, `*-data.json`, `*-chat.log`) are
git-ignored — they belong on your machine, not in the repo.

## License

MIT — see [LICENSE](LICENSE).
