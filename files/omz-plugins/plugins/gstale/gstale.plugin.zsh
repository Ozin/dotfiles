# gstale: find and manage stale branches by age and author
gstale() {
  (
    emulate -L zsh
    set -o pipefail

    # --- Helpers (scoped to subshell) ---
    _to_epoch() {
      local iso="$1"
      # Try GNU date
      if command -v date >/dev/null 2>&1; then
        date -d "$iso" +%s 2>/dev/null && return 0
        # macOS/BSD date
        date -j -f "%Y-%m-%d %H:%M:%S %z" "$iso" "+%s" 2>/dev/null && return 0
      fi
      # Fallback: Python (usually available in WSL/macOS/Linux)
      python3 - <<'PY' "$iso"
import sys, datetime, re
s = sys.argv[1]
try:
    print(int(datetime.datetime.fromisoformat(s.replace("Z","+00:00")).timestamp()))
except Exception:
    m = re.match(r"(\d{4}-\d{2}-\d{2}) T", s)
    if not m:
        print(0)
    else:
        print(int(datetime.datetime.fromisoformat(f"{m.group(1)} {m.group(2)}").timestamp()))
PY
    }

    _epoch_days_ago() {
      local days="${1:-7}"
      if command -v date >/dev/null 2>&1; then
        date -d "$days days ago" +%s 2>/dev/null && return 0
        date -v -"${days}"d +%s 2>/dev/null && return 0
      fi
      python3 - <<PY "$days"
import time, sys
days = int(sys.argv[1] or 7)
print(int(time.time()) - days*86400)
PY
    }

    _print_row() {
      # $1=ref $2=committerdate $3=author $4=sha
      printf "%s|%s|%s|%s\n" "$1" "$2" "$3" "$4"
    }

    _list_remote_refs() {
      git for-each-ref --sort=-committerdate refs/remotes/ \
        --format='%(refname:short)|%(committerdate:iso8601)|%(authorname)|%(objectname)'
    }

    _filter_older_than() {
      local days="${1:-7}"
      local cutoff="$(_epoch_days_ago "$days")"
      while IFS='|' read -r ref iso author sha; do
        [[ "$ref" == */HEAD ]] && continue
        local epoch="$(_to_epoch "$iso")"
        [[ -z "$epoch" || "$epoch" == "0" ]] && continue
        (( epoch < cutoff )) && echo "$ref|$iso|$author|$sha"
      done
    }

    _branch_has_commit_by_me() {
      local ref="$1"
      local me_name="$(git config user.name)"
      local me_mail="$(git config user.email)"
      [[ -z "$me_name" && -z "$me_mail" ]] && return 1
      # Match by name OR email
      git log "$ref" --pretty=format:%H \
        ${me_name:+--author="$me_name"} \
        ${me_mail:+--author="$me_mail"} 2>/dev/null | grep -q .
    }

    _default_branch() {
      local db
      db="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@refs/remotes/origin/@@')"
      [[ -n "$db" ]] && { echo "$db"; return; }
      for candidate in main master develop; do
        git show-ref --verify --quiet "refs/remotes/origin/$candidate" 2>/dev/null && { echo "$candidate"; return; }
      done
      echo "main"
    }

    # Prints "my_count/total" for commits on $ref not on the default branch.
    # Returns 0 if I authored the majority (>50%), 1 otherwise.
    _my_commit_majority() {
      local ref="$1" me_name="$2" me_mail="$3"
      local db="$(_default_branch)"
      local total my_count=0
      total=$(git rev-list --count "$ref" --not "origin/$db" 2>/dev/null)
      (( total == 0 )) && return 1
      [[ -n "$me_name" ]] && my_count=$(git rev-list --count "$ref" --not "origin/$db" --author="$me_name" 2>/dev/null)
      if (( my_count == 0 )) && [[ -n "$me_mail" ]]; then
        my_count=$(git rev-list --count "$ref" --not "origin/$db" --author="$me_mail" 2>/dev/null)
      fi
      echo "${my_count}/${total}"
      (( my_count * 2 > total ))
    }

    _maybe_column() {
      if command -v column >/dev/null 2>&1; then
        column -t -s '|'
      else
        cat
      fi
    }

    # --- Main ---
    local cmd="${1:-list}"
    local days="${2:-7}"
    local me_name="$(git config user.name)"
    local me_mail="$(git config user.email)"

    case "$cmd" in
      list)
        echo "Remote branches (older than ${days} days):"
        _list_remote_refs | _filter_older_than "$days" | _maybe_column
        ;;

      mine)
        [[ -z "$me_name" && -z "$me_mail" ]] && { echo "Git identity is not configured (user.name / user.email)."; exit 1; }
        echo "Stale branches (older than ${days} days) with last commit authored by you:"
        _list_remote_refs | _filter_older_than "$days" | while IFS='|' read -r ref iso author sha; do
          if [[ "$author" == "$me_name" || "$author" == "$me_mail" ]]; then
            _print_row "$ref" "$iso" "$author" "$sha"
          fi
        done | _maybe_column
        ;;

      mine-any)
        [[ -z "$me_name" && -z "$me_mail" ]] && { echo "Git identity is not configured (user.name / user.email)."; exit 1; }
        echo "Stale branches (older than ${days} days) where you authored any commit:"
        _list_remote_refs | _filter_older_than "$days" | while IFS='|' read -r ref iso author sha; do
          if _branch_has_commit_by_me "$ref"; then
            _print_row "$ref" "$iso" "$author" "$sha"
          fi
        done | _maybe_column
        ;;

      mine-majority)
        [[ -z "$me_name" && -z "$me_mail" ]] && { echo "Git identity is not configured (user.name / user.email)."; exit 1; }
        echo "Stale branches (older than ${days} days) where you authored the majority of commits:"
        local _mm_ratio _mm_branch
        _list_remote_refs | _filter_older_than "$days" | while IFS='|' read -r ref iso author sha; do
          _mm_branch="${ref#*/}"
          [[ "$_mm_branch" == "main" || "$_mm_branch" == "master" || "$_mm_branch" == "develop" ]] && continue
          if _mm_ratio="$(_my_commit_majority "$ref" "$me_name" "$me_mail")"; then
            printf "%s|%s|%s|%s|%s\n" "$ref" "$iso" "$author" "$sha" "$_mm_ratio"
          fi
        done | _maybe_column
        ;;

      delete)
        echo "Candidates (older than ${days} days):"
        # Gather candidates first
        local -a candidates
        while IFS= read -r line; do
          candidates+=("$line")
        done < <(_list_remote_refs | _filter_older_than "$days")

        if (( ${#candidates[@]} == 0 )); then
          echo "No candidates found."
          exit 0
        fi

        # Print table before prompting
        printf "%s\n" "${candidates[@]}" | _maybe_column

        echo
        echo "For each branch: choose action — [y] delete local, [r] delete remote + local, [Enter] skip."
        local -a actions
        for item in "${candidates[@]}"; do
          IFS='|' read -r ref iso author sha <<<"$item"
          printf "Delete %s ? [y/N/r]: " "$ref"
          read -r ans
          if [[ "$ans" == [yY] ]]; then
            actions+=("${ref}:local")
          elif [[ "$ans" == [rR] ]]; then
            actions+=("${ref}:remote")
          fi
        done

        if (( ${#actions[@]} == 0 )); then
          echo "No deletions selected."
          exit 0
        fi

        echo
        for item in "${actions[@]}"; do
          local ref="${item%%:*}"
          local mode="${item##*:}"
          local remote="${ref%%/*}"
          local branch="${ref#*/}"

          # Delete local tracking branch if it exists
          if git show-ref --verify --quiet "refs/heads/$branch"; then
            echo "Deleting local branch: $branch"
            git branch -D "$branch" > /dev/null
          fi
          if [[ "$mode" == "remote" ]]; then
            echo "Deleting remote branch: $remote/$branch"
            git push "$remote" --delete "$branch" > /dev/null
          fi
        done
        ;;

      sweep)
        [[ -z "$me_name" && -z "$me_mail" ]] && { echo "Git identity is not configured (user.name / user.email)."; exit 1; }

        local base_dir="$(pwd)"
        local tmpfile="$(mktemp)" delfile="$(mktemp)"
        trap "rm -f '$tmpfile' '$delfile'" EXIT INT TERM

        # --- Discover repos ---
        echo "Scanning git repos below ${base_dir} ..."
        local -a _sw_repos=()
        while IFS= read -r gitdir; do
          _sw_repos+=("${gitdir%/.git}")
        done < <(find "$base_dir" -name ".git" -type d 2>/dev/null | sort)

        (( ${#_sw_repos[@]} == 0 )) && { echo "No git repos found."; exit 0; }

        # --- Collect mine-majority branches ---
        local _sw_i=0
        for rdir in "${_sw_repos[@]}"; do
          (( _sw_i++ ))
          cd "$rdir" 2>/dev/null || continue
          local _sw_label="${rdir#${base_dir}/}"
          printf "\r\033[K  [%d/%d] %s" "$_sw_i" "${#_sw_repos[@]}" "$_sw_label"
          _list_remote_refs | _filter_older_than "$days" | while IFS='|' read -r ref iso author sha; do
            local _sw_branch="${ref#*/}"
            [[ "$_sw_branch" == "main" || "$_sw_branch" == "master" || "$_sw_branch" == "develop" ]] && continue
            if _sw_ratio="$(_my_commit_majority "$ref" "$me_name" "$me_mail")"; then
              printf "%s|%s|%s|%s\n" "$_sw_label" "$ref" "${iso%% *}" "$_sw_ratio" >> "$tmpfile"
            fi
          done
          cd "$base_dir"
        done
        printf "\r\033[K"

        local total
        total=$(wc -l < "$tmpfile" | tr -d ' ')
        (( total == 0 )) && { echo "No stale branches found across ${#_sw_repos[@]} repos. All clean! ✨"; exit 0; }

        # --- Display grouped by repo ---
        echo "Found $total stale branch(es) across ${#_sw_repos[@]} repos (>${days}d, majority yours):"
        echo
        local _sw_cur=""
        while IFS='|' read -r repo ref iso ratio; do
          if [[ "$repo" != "$_sw_cur" ]]; then
            [[ -n "$_sw_cur" ]] && echo
            echo "  📁 $repo"
            _sw_cur="$repo"
          fi
          printf "     %-60s  %s  %s\n" "${ref#*/}" "$iso" "$ratio"
        done < "$tmpfile"
        echo

        # --- Exclude pattern (optional) ---
        printf "Exclude pattern (regex to keep, or Enter for none): "
        read -r _sw_excl

        local filtered
        if [[ -n "$_sw_excl" ]]; then
          grep -v -E "$_sw_excl" "$tmpfile" > "$delfile" || true
          filtered=$(wc -l < "$delfile" | tr -d ' ')
          local excluded=$((total - filtered))
          echo "Keeping $excluded branch(es) matching '${_sw_excl}'. $filtered to delete."
        else
          cp "$tmpfile" "$delfile"
          filtered=$total
        fi

        (( filtered == 0 )) && { echo "Nothing to delete."; exit 0; }

        # Show filtered list if something was excluded
        if [[ -n "$_sw_excl" ]]; then
          echo
          _sw_cur=""
          while IFS='|' read -r repo ref iso ratio; do
            if [[ "$repo" != "$_sw_cur" ]]; then
              [[ -n "$_sw_cur" ]] && echo
              echo "  🗑  $repo"
              _sw_cur="$repo"
            fi
            printf "     %-60s  %s\n" "${ref#*/}" "$iso"
          done < "$delfile"
        fi
        echo

        printf "Delete $filtered branch(es) (remote + local + prune)? [y/N]: "
        read -r _sw_confirm
        [[ "$_sw_confirm" != [yY] ]] && { echo "Aborted."; exit 0; }
        echo

        # --- Execute deletions ---
        while IFS='|' read -r repo ref iso ratio; do
          local remote="${ref%%/*}" branch="${ref#*/}"
          printf "  %s → %s … " "$repo" "$branch"
          if git -C "$base_dir/$repo" push "$remote" --delete "$branch" >/dev/null 2>&1; then
            printf "remote ✓  "
          else
            printf "remote ✗  "
          fi
          if git -C "$base_dir/$repo" show-ref --verify --quiet "refs/heads/$branch"; then
            git -C "$base_dir/$repo" branch -D "$branch" >/dev/null 2>&1 && printf "local ✓\n" || printf "local ✗\n"
          else
            printf "(no local)\n"
          fi
        done < "$delfile"

        # --- Prune ---
        echo
        echo "Pruning tracking refs ..."
        awk -F'|' '!seen[$1]++ {print $1}' "$delfile" | while read -r repo; do
          git -C "$base_dir/$repo" remote prune origin >/dev/null 2>&1
        done
        echo "Done ✨"
        ;;

      *)
        cat <<'USAGE'
Usage:
  gstale list [DAYS]           # List remote branches older than DAYS

  gstale mine [DAYS]           # Stale branches whose last commit was authored by you
  gstale mine-any [DAYS]       # Stale branches where you authored any commit
  gstale mine-majority [DAYS]  # Stale branches where you authored >50% of commits
  gstale delete [DAYS]         # Interactively delete (local / remote+local)
  gstale sweep [DAYS]          # Multi-repo: find & delete your stale branches below cwd

Notes:
- "You" = matches git config user.name or user.email
- Default DAYS = 7
- HEAD refs are ignored
- mine-majority compares commits on branch vs default branch (main/master)
- sweep discovers all git repos below cwd, collects mine-majority branches,
  lets you exclude a regex pattern, then bulk-deletes (remote + local + prune)
- Output is aligned using `column -t -s '|'` if available
USAGE
        ;;
    esac
  )
}
