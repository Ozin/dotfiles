---
description: Connect the KeePassXC browser extension in Flatpak Zen to native KeePassXC. The sandbox blocks it; the fix is a wrapper that runs the host keepassxc-proxy via `flatpak-spawn --host` plus two flatpak overrides. Gotcha — KeePassXC rewrites the manifest on restart unless CustomProxyLocation points at the wrapper.
keywords:
  - zen browser
  - flatpak
  - keepassxc
  - keepassxc-browser
  - browser integration
  - native messaging
  - native-messaging-hosts
  - flatpak-spawn
  - keepassxc-proxy
  - sandbox
  - password manager
  - cannot connect to keepassxc
  - org.keepassxc.keepassxc_browser
---

# Connecting Flatpak Zen Browser to native KeePassXC

**Status:** working solution · **Last verified:** 2026-06-05 · Zen 1.20.1b, KeePassXC 2.7.12, Linux

## TL;DR

The KeePassXC browser extension talks to KeePassXC through a helper binary
(`keepassxc-proxy`) launched by the browser via _native messaging_. Zen runs in
a Flatpak sandbox, so it can't see or run the host's `keepassxc-proxy`. The fix
is a tiny **wrapper script** that hops out of the sandbox with
`flatpak-spawn --host` and runs the real proxy on the host. Two Flatpak
permission grants make that hop legal and make the manifest visible.

```
extension → Zen → manifest → wrapper.sh → flatpak-spawn --host → keepassxc-proxy → KeePassXC
```

## Assumptions

- **Zen** installed as Flatpak: app id `app.zen_browser.zen`.
- **KeePassXC** installed natively (host), providing `/usr/bin/keepassxc-proxy`.
  Browser Integration is enabled in KeePassXC settings.
- The keepassxc-browser extension is already installed in Zen.

If KeePassXC is _also_ a Flatpak, this guide does not apply — use KeePassXC's
own browser-integration support instead.

## Why the sandbox breaks it

- Inside the sandbox, `/usr/bin/keepassxc-proxy` is the Flatpak runtime's `/usr`,
  **not** the host — so the real proxy isn't there to run.
- Zen looks for native-messaging manifests in `~/.mozilla/native-messaging-hosts/`
  (the base is hardcoded to `.mozilla` in Gecko, even though Zen's profile lives
  in `~/.zen`). That directory isn't exposed to the sandbox by default.
- The sandbox's `$HOME` is `/home/<user>`; granting `--filesystem=~/.mozilla`
  maps the real `~/.mozilla` to the same path inside, so a path written in the
  manifest is valid both inside and outside the sandbox.

## Setup (copy-paste)

```bash
APPID=app.zen_browser.zen
DIR="$HOME/.mozilla/native-messaging-hosts"
WRAPPER="$DIR/keepassxc-proxy-wrapper.sh"

mkdir -p "$DIR"

# 1) Wrapper: run the HOST proxy from inside the sandbox, pipe stdio through.
cat > "$WRAPPER" <<'EOF'
#!/bin/sh
exec flatpak-spawn --host /usr/bin/keepassxc-proxy "$@"
EOF
chmod +x "$WRAPPER"

# 2) Native-messaging manifest pointing at the wrapper.
#    NOTE: the path must be absolute; $HOME expands to the same /home/<user>
#    string the sandbox sees, so this is valid inside the sandbox too.
cat > "$DIR/org.keepassxc.keepassxc_browser.json" <<EOF
{
    "allowed_extensions": [ "keepassxc-browser@keepassxc.org" ],
    "description": "KeePassXC integration with native messaging support",
    "name": "org.keepassxc.keepassxc_browser",
    "path": "$WRAPPER",
    "type": "stdio"
}
EOF

# 3) Two Flatpak overrides:
#    - talk to org.freedesktop.Flatpak  -> enables `flatpak-spawn --host`
#    - expose ~/.mozilla (read-only)    -> lets Zen see the manifest
flatpak override --user --talk-name=org.freedesktop.Flatpak "$APPID"
flatpak override --user --filesystem="$HOME/.mozilla:ro" "$APPID"
```

Then **fully quit and reopen Zen** (overrides only apply to a fresh sandbox),
make sure KeePassXC is running and unlocked, and click the keepassxc-browser
icon → it should connect and prompt you to name/associate the database.

## Make it durable (important — otherwise it breaks in a few days)

KeePassXC's _"Update native messaging manifest files at startup"_ rewrites the
manifest's `path` on restart, replacing the wrapper with the default
`/usr/bin/keepassxc-proxy` — which doesn't exist in the sandbox, silently
breaking the connection. Point KeePassXC's custom proxy location at the wrapper
so the auto-update writes the _correct_ path instead:

> **KeePassXC → Settings → Browser Integration → Advanced →
> tick "Use a custom proxy location"** (this toggle is what actually matters —
> setting the path without ticking it is ignored), and set the location to:
>
> ```
> ~/.mozilla/native-messaging-hosts/keepassxc-proxy-wrapper.sh
> ```

Equivalent in `~/.config/keepassxc/keepassxc.ini` — **both** keys are required;
`UseCustomProxy=true` is the one that's easy to miss. Edit only while KeePassXC
is **closed**, or it gets overwritten on exit:

```ini
[Browser]
UseCustomProxy=true
CustomProxyLocation=~/.mozilla/native-messaging-hosts/keepassxc-proxy-wrapper.sh
```

(KeePassXC stores an absolute path here; the GUI fills it in for you when you
browse to the wrapper.)

## Verify the whole chain

Sends the real `change-public-keys` handshake (4-byte little-endian length +
JSON) through the sandbox. A reply with `"success":"true"` and KeePassXC's
public key proves sandbox → wrapper → proxy → KeePassXC works:

```bash
python3 - <<'PY'
import base64, json, os, struct, subprocess, sys
msg = {"action":"change-public-keys",
       "publicKey": base64.b64encode(os.urandom(32)).decode(),
       "nonce":     base64.b64encode(os.urandom(24)).decode(),
       "clientID":  base64.b64encode(os.urandom(24)).decode()}
payload = json.dumps(msg).encode()
wrapper = os.path.expanduser("~/.mozilla/native-messaging-hosts/keepassxc-proxy-wrapper.sh")
p = subprocess.Popen(["flatpak","run","--command=sh","app.zen_browser.zen","-c","exec "+wrapper],
                     stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
p.stdin.write(struct.pack("<I", len(payload)) + payload); p.stdin.flush()
hdr = p.stdout.read(4)
if len(hdr) < 4: print("NO RESPONSE"); p.kill(); sys.exit(1)
print(json.dumps(json.loads(p.stdout.read(struct.unpack("<I", hdr)[0])), indent=2)); p.kill()
PY
```

## Troubleshooting

| Symptom                                  | Check                                                                                                                                            |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Stopped working after days               | Manifest `path` reverted to `/usr/bin/keepassxc-proxy` — set CustomProxyLocation (see "Make it durable"), then restore the manifest.             |
| `Portal call failed: ... ServiceUnknown` | Missing `--talk-name=org.freedesktop.Flatpak` override.                                                                                          |
| Extension can't find host                | Missing `--filesystem=~/.mozilla:ro` override, or Zen wasn't fully restarted. Confirm with `flatpak override --user --show app.zen_browser.zen`. |
| No response in verify script             | KeePassXC not running, locked, or Browser Integration disabled.                                                                                  |

Inspect current overrides:

```bash
flatpak override --user --show app.zen_browser.zen
```

## Files this touches (not managed by Ansible)

These live in `$HOME`, not in this repo — they are documented here, not symlinked:

- `~/.mozilla/native-messaging-hosts/keepassxc-proxy-wrapper.sh`
- `~/.mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json`
- `~/.local/share/flatpak/overrides/app.zen_browser.zen` (the two overrides)
