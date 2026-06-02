# dnf (Fedora/RHEL) support for dotfiles bootstrap

**Date:** 2026-06-02
**Status:** Approved (pending user review)

## Goal

Make the dotfiles bootstrap (`setup.sh` + the Ansible playbook) run end-to-end on
Fedora-family systems (dnf), in addition to the existing Debian/Ubuntu/WSL (apt)
support. Triggered by running the bootstrap on Nobara (Fedora 43), where
`setup.sh` and several Ansible roles hardcode `apt`.

Secondary goal: move the JVM toolchain (Java, Maven) from system packages to
SDKMAN, using GraalVM / latest Java.

## Non-goals

- Supporting Arch, Alpine, macOS, or other package managers.
- Reworking roles that are already distro-agnostic (`shell`, `git`, `nvm`,
  `dotfiles`, `tmux`, most of `tools`).

## Design

### A. `setup.sh` — package-manager detection

Replace the hardcoded `apt-get` Ansible install with detection:

- `apt-get` present → `sudo apt-get update -qq && sudo apt-get install -y -qq ansible`
- else `dnf` present → `sudo dnf install -y ansible`
- else → `err` with a clear message.

Update the OS-check message (currently "Only WSL2/Ubuntu is supported") to reflect
that native Linux (incl. Fedora) is supported.

### B. `apt` role → `packages` role (per-OS vars + generic module)

Rename `ansible/roles/apt` → `ansible/roles/packages`; update the role name and
tag in `ansible/site.yml` (`apt` → `packages`).

Layout:

```
ansible/roles/packages/
  tasks/main.yml
  vars/Debian.yml
  vars/RedHat.yml
```

`tasks/main.yml`:

1. `include_vars: "{{ ansible_os_family }}.yml"` → loads `Debian.yml` or `RedHat.yml`.
2. WSL detection: `set_fact: is_wsl: "{{ 'microsoft' in (ansible_kernel | lower) }}"`.
3. apt cache update — `ansible.builtin.apt: update_cache: true`, gated
   `when: ansible_os_family == "Debian"`.
4. Install `system_packages` via `ansible.builtin.package` (dispatches to apt/dnf).
5. Install `wsl_packages` via `ansible.builtin.package`, gated `when: is_wsl`.

Package set changes vs. today's flat list:

- **Moved to SDKMAN (removed here):** `openjdk-21-jdk`, `openjdk-25-jdk`, `maven`.
- **Moved to `wsl_packages` (install only under WSL):** `wslu`, `x11-apps`.
- **Debian.yml** — remaining current names unchanged.
- **RedHat.yml** — Fedora names:
  | Debian | Fedora |
  |---|---|
  | `gnupg` | `gnupg2` |
  | `python3.12-venv` | *(dropped — venv ships in `python3`)* |
  | `x11-apps` | `xorg-x11-apps` (wsl_packages) |
  | *(n/a)* | `fuse-libs` (added — Neovim AppImage in `tools` needs FUSE) |
  | all others (`bat`, `coreutils`, `curl`, `diffutils`, `findutils`, `gcc`, `golang`, `grep`, `gzip`, `highlight`, `jq`, `make`, `mkcert`, `podman`, `ripgrep`, `tmux`, `tree`, `unzip`, `xclip`, `zip`, `zsh`) | same name |

  `wsl_packages` on RedHat: empty (Fedora-on-WSL is uncommon; `wslu` is COPR-only —
  can be added later if needed).

### C. `sdkman` role — Java (GraalVM) + Maven

Add, alongside the existing Gradle install:

- Install each entry of `sdkman_java_versions` via `sdk install java <id>`
  (idempotent via `creates: ~/.sdkman/candidates/java/<id>`).
- Set `sdkman_java_default` as the default JDK (`sdk default java <id>`).
- Install Maven via `sdk install maven` (`creates: ~/.sdkman/candidates/maven/current/bin/mvn`).

New vars in `group_vars/all.yml` (GraalVM / latest, user-bumpable):

```yaml
sdkman_java_versions:
  - "25-graal"      # Oracle GraalVM, latest Java
sdkman_java_default: "25-graal"
```

(Identifiers are SDKMAN's; major-only form is stable for Oracle GraalVM. Bump as
new majors land.)

### D. `k8s` role — RPM repo for Fedora

- Keep apt signing-key + apt repo tasks, gated `when: ansible_os_family == "Debian"`.
- Add `ansible.builtin.yum_repository` (RedHat) for
  `https://pkgs.k8s.io/core:/stable:/{{ kubectl_repo_version }}/rpm/`
  with `gpgkey: .../rpm/repodata/repomd.xml.key`, gated `when: ansible_os_family == "RedHat"`.
- Install `kubectl` via `ansible.builtin.package` (drop the apt-specific module;
  keep a Debian-only `apt: update_cache: true` after adding the repo).
- Helm / k9s install unchanged (already distro-agnostic).

### E. `tools` role — OpenTofu without snap

snap is not available by default on Fedora. Replace the `community.general.snap`
install + `/snap/...` symlink with a direct binary download from GitHub releases
(`opentofu/opentofu`, `tofu_<ver>_linux_amd64.zip`), mirroring the existing
Terraform/k9s pattern, into `{{ local_bin }}`. Add `opentofu_version: "latest"`
to `group_vars/all.yml`.

### F. Git identity + commits

- Set repo git config `user.name "Ozin"`, `user.email "Ozin@users.noreply.github.com"`
  (matches the last commit) so future commits use it.
- Make meaningful, scoped commits (one per coherent change: setup.sh, packages
  role, sdkman, k8s, tools).

## Testing / verification

- `bash -n setup.sh` and shell review of the detection branch.
- `ansible-playbook ansible/site.yml --syntax-check`.
- `ansible-lint` if available.
- Manual: dry-run / targeted tag runs where feasible on the Fedora host.
- Confirm `gather_facts: true` (already set) so `ansible_os_family` / `ansible_kernel`
  are populated.

## Risks

- SDKMAN GraalVM identifiers can drift; mitigated by keeping them in vars.
- Fedora package-name assumptions (`gnupg2`, `fuse-libs`, `xorg-x11-apps`) — verified
  against current Fedora repos; if any differ on Nobara specifically, adjust `RedHat.yml`.
- `java-25` may be unavailable as a Fedora system package — avoided entirely by the
  SDKMAN move.
