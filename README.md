# nwpcs-wlanReport

Linux equivalent of `netsh wlan show networks` + `netsh wlanreport`.

Scan nearby Wi-Fi networks and generate a single-file HTML report you can
open in any browser (`file://` — no server needed), or serve over HTTP.
Ships with an ASCII-art banner, chat-style progress log, and an interactive
chatbox mode. On a terminal it plays a short animated signal intro and shows
spinners during long steps — automatically disabled when piped, and manually
with `--no-animate` (plus `--no-banner` / `--no-color` for calm output).

## Requirements

- Linux with NetworkManager (`nmcli`), `iw`, `ip` (+ optional `ping`, `journalctl`, `lspci`)
- Python 3.9+ (stdlib only — no dependencies)
- A Wi-Fi adapter with driver loaded. Missing/optional pieces degrade gracefully;
  run `wlan-report check-deps` first — it tells you exactly what's absent and how
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
install -m755 wlan-report ~/.local/bin/wlan-report
wlan-report check-deps
```

> The event-log section needs journal read access. If `check-deps` reports the
> journal as LIMITED, run `sudo usermod -aG systemd-journal $USER`, re-login,
> and re-run. Everything else keeps working without it.

## Usage

```bash
wlan-report check-deps                     # verify tools + permissions first
wlan-report check-deps --json              # machine-readable readiness
wlan-report scan                          # terminal table (like netsh wlan show networks)
wlan-report scan --json --limit 10 --sort signal|channel|ssid
wlan-report info                          # current connection summary
wlan-report chat                          # interactive chatbox mode
wlan-report report                        # -> ~/wlan-report.html + -data.json + -chat.log
wlan-report report -o /tmp/wifi.html --open
wlan-report open                            # open ~/wlan-report.html in your browser
wlan-report report --serve --port 8000    # generate + serve + open browser
wlan-report serve ~/wlan-report.html --port 8000 --open
wlan-report --iface wlo1 report -o out.html
wlan-report --no-banner scan              # skip the ASCII banner
```

### Chat mode

```
$ wlan-report chat
you> scan
you> report -o /tmp/wifi.html
you> open
you> exit
```

Commands: `check | scan | info | report [-o file] | open | serve [port] | log | clear | help | exit`.
The transcript is saved to `~/wlan-report-chat.log`.

### Sharing reports

The HTML embeds nearby SSIDs/BSSIDs plus your local IP and MAC. Fine for
personal use — think twice before posting a raw report publicly.

## Report contents

Summary KPIs, recommendations (congestion, weak WPA1/TKIP, band advice),
adapter details, current connection + `iw link`/`station` dumps, sortable and
filterable network table, channel utilization + signal ranking charts,
band/security breakdown, ping/DNS/route diagnostics, NetworkManager event log,
session chat log with an in-browser notes chatbox, and the exact collection
commands (Windows parity table included).

## Windows parity

| Windows                          | This tool              |
|----------------------------------|------------------------|
| `netsh wlan show networks mode=bssid` | `wlan-report scan` |
| `netsh wlanreport`               | `wlan-report report --open` |

## Layout

```
nwpcs-wlanReport/
├── wlan-report   # the CLI (single-file, executable, stdlib-only)
├── install.sh    # one-line installer (curl … | bash)
├── README.md
├── LICENSE
└── .gitignore
```

Generated artifacts (`wlan-report.html`, `*-data.json`, `*-chat.log`) are
git-ignored — they belong on your machine, not in the repo.

## License

MIT — see [LICENSE](LICENSE).
