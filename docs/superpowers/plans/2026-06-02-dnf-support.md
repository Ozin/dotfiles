# dnf (Fedora) Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `setup.sh` and the Ansible playbook run end-to-end on Fedora-family (dnf) systems in addition to Debian/Ubuntu/WSL (apt), and move the JVM toolchain to SDKMAN (GraalVM/latest Java).

**Architecture:** `setup.sh` detects apt-get vs dnf. The `apt` role becomes a distro-agnostic `packages` role using per-OS vars files (`Debian.yml`/`RedHat.yml`) and the generic `ansible.builtin.package` module. The `k8s` role gains an RPM repo path; `tools` swaps snap→binary for OpenTofu; `sdkman` gains Java+Maven.

**Tech Stack:** Bash, Ansible (built-in apt/dnf/package/yum_repository modules), SDKMAN.

**Commit convention for this repo:** one-line commit messages only (no body, no trailers). Git identity is already set to `Ozin <Ozin@users.noreply.github.com>`.

---

### Task 1: `setup.sh` — package-manager detection

**Files:**
- Modify: `setup.sh:19-21` (OS-check message) and `setup.sh:31-36` (Ansible install)

- [ ] **Step 1: Update the OS-check message**

Replace lines 19-21:

```bash
# OS check
if ! grep -qi microsoft /proc/version 2>/dev/null && [[ "$(uname -s)" != "Linux" ]]; then
  err "Unsupported OS. Only WSL2/Ubuntu is supported."
fi
```

with:

```bash
# OS check
if [[ "$(uname -s)" != "Linux" ]]; then
  err "Unsupported OS. Only Linux (incl. WSL2) is supported."
fi
```

- [ ] **Step 2: Replace the Ansible install block with package-manager detection**

Replace lines 31-36:

```bash
# Install Ansible
if ! command -v ansible-playbook &>/dev/null; then
  info "Installing Ansible..."
  sudo apt-get update -qq
  sudo apt-get install -y -qq ansible
fi
```

with:

```bash
# Install Ansible
if ! command -v ansible-playbook &>/dev/null; then
  info "Installing Ansible..."
  if command -v apt-get &>/dev/null; then
    sudo apt-get update -qq
    sudo apt-get install -y -qq ansible
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y ansible
  else
    err "No supported package manager found (need apt-get or dnf)."
  fi
fi
```

- [ ] **Step 3: Verify the script parses**

Run: `bash -n setup.sh`
Expected: no output, exit 0.

- [ ] **Step 4: Commit**

```bash
git add setup.sh
git commit -m "feat(setup): detect apt-get or dnf for Ansible install"
```

---

### Task 2: Rename `apt` role → `packages` with per-OS vars

**Files:**
- Rename: `ansible/roles/apt/` → `ansible/roles/packages/`
- Rewrite: `ansible/roles/packages/tasks/main.yml`
- Create: `ansible/roles/packages/vars/main.yml` (single source of truth — shared list + per-OS override map)
- Modify: `ansible/site.yml:8-9` (role name + tag)

- [ ] **Step 1: Rename the role directory (preserve history)**

Run: `git mv ansible/roles/apt ansible/roles/packages`

- [ ] **Step 2: Update `ansible/site.yml`**

Replace lines 8-9:

```yaml
    - role: apt
      tags: [apt]
```

with:

```yaml
    - role: packages
      tags: [packages]
```

- [ ] **Step 3: Rewrite `ansible/roles/packages/tasks/main.yml`**

`vars/main.yml` is auto-loaded by the role, so no `include_vars` is needed. Full new contents:

```yaml
---
- name: Detect WSL environment
  ansible.builtin.set_fact:
    is_wsl: "{{ 'microsoft' in (ansible_kernel | lower) }}"

- name: Update apt cache (Debian)
  become: true
  ansible.builtin.apt:
    update_cache: true
    cache_valid_time: 3600
  when: ansible_os_family == "Debian"

- name: Install system packages
  become: true
  ansible.builtin.package:
    name: "{{ system_packages }}"
    state: present

- name: Install WSL-specific packages
  become: true
  ansible.builtin.package:
    name: "{{ wsl_packages }}"
    state: present
  when: is_wsl and (wsl_packages | length > 0)
```

- [ ] **Step 4: Create `ansible/roles/packages/vars/main.yml` (single source of truth)**

`common_packages` holds every package with an identical name across distros; only genuine differences go in `package_overrides`. `system_packages`/`wsl_packages` are derived from `ansible_os_family`. Full contents:

```yaml
---
# Packages with the same name on every supported distro.
common_packages:
  - bat
  - coreutils
  - curl
  - diffutils
  - findutils
  - gcc
  - golang
  - grep
  - gzip
  - highlight
  - jq
  - make
  - mkcert
  - podman
  - ripgrep
  - tmux
  - tree
  - unzip
  - xclip
  - zip
  - zsh

# Packages whose name (or presence) differs by OS family.
# Debian: gnupg, python venv shipped separately.
# RedHat: gnupg2, venv bundled in python3, fuse-libs for the Neovim AppImage.
package_overrides:
  Debian:
    - gnupg
    - python3.12-venv
  RedHat:
    - gnupg2
    - python3
    - fuse-libs

# WSL-only packages, by OS family (X11 utils only matter under WSL).
wsl_packages_by_os:
  Debian:
    - wslu
    - x11-apps
  RedHat: []

system_packages: "{{ common_packages + package_overrides[ansible_os_family] }}"
wsl_packages: "{{ wsl_packages_by_os[ansible_os_family] }}"
```

- [ ] **Step 5: Verify playbook syntax**

Run: `ansible-playbook ansible/site.yml -i ansible/inventory/localhost.yml --syntax-check`
Expected: prints the playbook path with no errors, exit 0.

- [ ] **Step 6: Commit**

```bash
git add ansible/site.yml ansible/roles/packages
git commit -m "refactor(packages): replace apt role with distro-agnostic packages role"
```

---

### Task 3: SDKMAN — Java (GraalVM) + Maven

**Files:**
- Modify: `ansible/roles/sdkman/tasks/main.yml` (append tasks)
- Modify: `ansible/group_vars/all.yml` (add SDKMAN vars)

- [ ] **Step 1: Add SDKMAN vars to `ansible/group_vars/all.yml`**

Append at the end of the file:

```yaml

# SDKMAN-managed JVM toolchain (GraalVM / latest Java)
sdkman_java_versions:
  - "25-graal"
sdkman_java_default: "25-graal"
```

- [ ] **Step 2: Append Java + Maven tasks to `ansible/roles/sdkman/tasks/main.yml`**

Append after the existing "Install Gradle via SDKMAN" task:

```yaml

- name: Install Java versions via SDKMAN
  ansible.builtin.shell: |
    source {{ home_dir }}/.sdkman/bin/sdkman-init.sh && sdk install java {{ item }}
  args:
    executable: /bin/bash
    creates: "{{ home_dir }}/.sdkman/candidates/java/{{ item }}"
  loop: "{{ sdkman_java_versions }}"

- name: Set default Java via SDKMAN
  ansible.builtin.shell: |
    source {{ home_dir }}/.sdkman/bin/sdkman-init.sh && sdk default java {{ sdkman_java_default }}
  args:
    executable: /bin/bash
  changed_when: false

- name: Install Maven via SDKMAN
  ansible.builtin.shell: |
    source {{ home_dir }}/.sdkman/bin/sdkman-init.sh && sdk install maven
  args:
    executable: /bin/bash
    creates: "{{ home_dir }}/.sdkman/candidates/maven/current/bin/mvn"
```

- [ ] **Step 3: Verify playbook syntax**

Run: `ansible-playbook ansible/site.yml -i ansible/inventory/localhost.yml --syntax-check`
Expected: no errors, exit 0.

- [ ] **Step 4: Commit**

```bash
git add ansible/roles/sdkman/tasks/main.yml ansible/group_vars/all.yml
git commit -m "feat(sdkman): manage GraalVM Java and Maven via SDKMAN"
```

---

### Task 4: `k8s` role — RPM repo for Fedora

**Files:**
- Modify: `ansible/roles/k8s/tasks/main.yml:1-21` (repo + kubectl install)

- [ ] **Step 1: Replace the apt-only repo/install tasks (lines 1-21)**

Replace:

```yaml
---
- name: Add Kubernetes apt signing key
  become: true
  ansible.builtin.shell: |
    curl -fsSL https://pkgs.k8s.io/core:/stable:/{{ kubectl_repo_version }}/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  args:
    creates: /etc/apt/keyrings/kubernetes-apt-keyring.gpg

- name: Add Kubernetes apt repository
  become: true
  ansible.builtin.copy:
    content: "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/{{ kubectl_repo_version }}/deb/ /\n"
    dest: /etc/apt/sources.list.d/kubernetes.list
    mode: "0644"

- name: Install kubectl
  become: true
  ansible.builtin.apt:
    name: kubectl
    state: present
    update_cache: true
```

with:

```yaml
---
- name: Ensure apt keyrings directory exists (Debian)
  become: true
  ansible.builtin.file:
    path: /etc/apt/keyrings
    state: directory
    mode: "0755"
  when: ansible_os_family == "Debian"

- name: Add Kubernetes apt signing key (Debian)
  become: true
  ansible.builtin.shell: |
    curl -fsSL https://pkgs.k8s.io/core:/stable:/{{ kubectl_repo_version }}/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  args:
    creates: /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  when: ansible_os_family == "Debian"

- name: Add Kubernetes apt repository (Debian)
  become: true
  ansible.builtin.copy:
    content: "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/{{ kubectl_repo_version }}/deb/ /\n"
    dest: /etc/apt/sources.list.d/kubernetes.list
    mode: "0644"
  when: ansible_os_family == "Debian"

- name: Update apt cache (Debian)
  become: true
  ansible.builtin.apt:
    update_cache: true
  when: ansible_os_family == "Debian"

- name: Add Kubernetes yum repository (RedHat)
  become: true
  ansible.builtin.yum_repository:
    name: kubernetes
    description: Kubernetes
    baseurl: "https://pkgs.k8s.io/core:/stable:/{{ kubectl_repo_version }}/rpm/"
    gpgcheck: true
    gpgkey: "https://pkgs.k8s.io/core:/stable:/{{ kubectl_repo_version }}/rpm/repodata/repomd.xml.key"
    enabled: true
  when: ansible_os_family == "RedHat"

- name: Install kubectl
  become: true
  ansible.builtin.package:
    name: kubectl
    state: present
```

Leave the remaining tasks (Helm, local bin, k9s) unchanged.

- [ ] **Step 2: Verify playbook syntax**

Run: `ansible-playbook ansible/site.yml -i ansible/inventory/localhost.yml --syntax-check`
Expected: no errors, exit 0.

- [ ] **Step 3: Commit**

```bash
git add ansible/roles/k8s/tasks/main.yml
git commit -m "feat(k8s): add Kubernetes RPM repo and generic kubectl install"
```

---

### Task 5: `tools` role — OpenTofu without snap

**Files:**
- Modify: `ansible/roles/tools/tasks/main.yml:83-96` (OpenTofu section)
- Modify: `ansible/group_vars/all.yml` (add `opentofu_version`)

- [ ] **Step 1: Add `opentofu_version` to `ansible/group_vars/all.yml`**

In the "Tool versions" section, add the line after `terraform_version: "latest"`:

```yaml
opentofu_version: "latest"
```

- [ ] **Step 2: Replace the OpenTofu snap tasks (lines 83-96)**

Replace:

```yaml
# --- OpenTofu ---

- name: Install OpenTofu via snap
  become: true
  community.general.snap:
    name: opentofu
    classic: true

- name: Symlink OpenTofu to local bin
  ansible.builtin.file:
    src: /snap/opentofu/current/tofu
    dest: "{{ local_bin }}/tofu"
    state: link
    force: true
```

with:

```yaml
# --- OpenTofu ---

- name: Get latest OpenTofu version
  ansible.builtin.uri:
    url: https://api.github.com/repos/opentofu/opentofu/releases/latest
    return_content: true
  register: opentofu_release
  when: opentofu_version == "latest"

- name: Set OpenTofu download version
  ansible.builtin.set_fact:
    opentofu_dl_version: "{{ (opentofu_release.json.tag_name | regex_replace('^v', '')) if opentofu_version == 'latest' else opentofu_version }}"

- name: Download and extract OpenTofu
  ansible.builtin.unarchive:
    src: "https://github.com/opentofu/opentofu/releases/download/v{{ opentofu_dl_version }}/tofu_{{ opentofu_dl_version }}_linux_amd64.zip"
    dest: "{{ local_bin }}"
    remote_src: true
    include:
      - tofu
    mode: "0755"
    creates: "{{ local_bin }}/tofu"
```

- [ ] **Step 3: Verify playbook syntax**

Run: `ansible-playbook ansible/site.yml -i ansible/inventory/localhost.yml --syntax-check`
Expected: no errors, exit 0.

- [ ] **Step 4: Commit**

```bash
git add ansible/roles/tools/tasks/main.yml ansible/group_vars/all.yml
git commit -m "feat(tools): install OpenTofu from release binary instead of snap"
```

---

### Task 6: Final verification

**Files:** none (verification only)

- [ ] **Step 1: Full syntax check**

Run: `ansible-playbook ansible/site.yml -i ansible/inventory/localhost.yml --syntax-check`
Expected: no errors, exit 0.

- [ ] **Step 2: Lint (if available)**

Run: `command -v ansible-lint >/dev/null && ansible-lint ansible/ || echo "ansible-lint not installed, skipping"`
Expected: no errors (or skip message).

- [ ] **Step 3: Confirm no stray `apt` references remain outside Debian-gated tasks**

Run: `grep -rn "ansible.builtin.apt\|apt-get\|community.general.snap" ansible/ setup.sh`
Expected: every `ansible.builtin.apt` hit is inside a `when: ansible_os_family == "Debian"` task; no `community.general.snap`; `apt-get` only in `setup.sh`'s detection branch.

- [ ] **Step 4: Confirm git identity on the commits**

Run: `git log --format='%an <%ae>' -6 | sort -u`
Expected: only `Ozin <Ozin@users.noreply.github.com>`.

---

## Self-Review notes

- **Spec coverage:** A→Task 1, B→Task 2, C→Task 3, D→Task 4, E→Task 5, F→git identity (already set) + one-line commits throughout + Task 6 Step 4. All spec sections mapped.
- **Type/name consistency:** vars `system_packages`, `wsl_packages`, `is_wsl`, `sdkman_java_versions`, `sdkman_java_default`, `opentofu_version`/`opentofu_dl_version` used consistently across tasks.
- **No placeholders:** every code step shows full file content or exact replacement.
