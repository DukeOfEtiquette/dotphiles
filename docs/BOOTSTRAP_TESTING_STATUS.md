# Bootstrap Testing Status

**Last Updated:** 2024-12-31
**Branch:** `feature/bootstrap-setup`
**Status:** Dry-run passed all stages - ready for full test

---

## Summary

Created a comprehensive bootstrap system for setting up fresh Debian 11/12/13 machines. Testing revealed two bugs which have now been fixed. Ready for re-testing.

---

## What Was Built

### New Files Created

```
dotfiles/
├── bootstrap.sh                      # Main orchestrator
├── setup/
│   ├── lib/
│   │   ├── common.sh                 # Logging, prompts, idempotency
│   │   ├── packages.sh               # Package management helpers
│   │   └── verify.sh                 # Verification functions
│   ├── manifests/
│   │   ├── packages-core.txt         # curl, wget, git, etc.
│   │   ├── packages-dev.txt          # cmake, make, gcc, etc.
│   │   └── packages-desktop.txt      # i3, terminal, utilities
│   ├── 00-preflight.sh               # System checks
│   ├── 01-packages-core.sh           # Core packages
│   ├── 02-shell.sh                   # zsh + oh-my-zsh
│   ├── 03-git-config.sh              # Git setup + SSH key
│   ├── 04-packages-dev.sh            # Build toolchain
│   ├── 05-packages-desktop.sh        # Desktop environment
│   ├── 06-nvm.sh                     # Node Version Manager
│   ├── 07-docker.sh                  # Docker CE
│   ├── 08-apps-external.sh           # Chrome, VSCode, Discord
│   ├── 09-dotfiles.sh                # Runs installDotfiles.sh
│   └── 10-post-install.sh            # Final verification
├── docs/
│   ├── SETUP_GUIDE.md
│   ├── TROUBLESHOOTING.md
│   └── UPGRADE_DEBIAN.md             # Consolidated upgrade checklists
└── README.md                         # Updated with bootstrap info
```

### Files Modified

- `CLAUDE.md` - Added bootstrap documentation
- `README.md` - Simplified, points to bootstrap

### Files NOT Modified

- `installDotfiles.sh` - Kept unchanged (called by stage 09)

---

## Bugs Found During Testing

### Bug 1: Preflight requires `curl` but `curl` isn't installed on minimal Debian ✅ FIXED

**File:** `setup/00-preflight.sh`

**Problem:** The preflight check includes `curl` in the essential commands list, but `curl` is not present on a minimal Debian 11 install.

**Fix applied:** Removed `curl` from the essential commands check:
```bash
local essential_cmds=("bash" "grep" "sed" "awk" "tar")
```

---

### Bug 2: `--dry-run` stops after preflight ✅ FIXED

**File:** `bootstrap.sh`

**Problem:** `((stage_num++))` with `set -e` returns exit code 1 when `stage_num=0` (post-increment returns old value, 0 is falsy).

**Fix applied:** Changed to pre-increment `((++stage_num))` which returns 1 (truthy).

---

### Bug 3: `--dry-run` stops at stage 2 (shell) ✅ FIXED

**File:** `setup/lib/common.sh`

**Problem:** `stage_verify` ran actual verification in dry-run mode, failing because packages weren't installed.

**Fix applied:** Added `$DRY_RUN` check to skip verification and just log what would be verified.

---

### Bug 4: `--dry-run` stops at stage 4 (dev packages) ✅ FIXED

**File:** `setup/lib/verify.sh`

**Problem:** `verify_command_version`, `verify_service_running`, and `verify_group_membership` were called directly and failed in dry-run mode.

**Fix applied:** Added `$DRY_RUN` checks to these functions.

---

### Bug 5: git config runs in dry-run mode ✅ FIXED

**File:** `setup/03-git-config.sh`

**Problem:** `git config` commands weren't checking `$DRY_RUN`.

**Fix applied:** Added `$DRY_RUN` checks around all `git config` commands.

---

## Test Environment

### VM Setup

- **Hypervisor:** VirtualBox (on Debian 11 host with 5.10.0-37 kernel)
- **VM Name:** `debian-bootstrap-test`
- **VM OS:** Debian 11 (Bullseye) fresh install with GNOME desktop
- **VM User:** `aduquette` (added to sudo group manually after install)
- **VM Snapshot:** "Fresh Install" taken before testing
- **Network:** NAT with port forwarding (Host 2222 → Guest 22)
- **SSH:** openssh-server installed, SCP working from host

### How to Update VM After Fixes

From the host machine:
```bash
# Copy updated dotfiles to VM
scp -r -P 2222 ~/.everc/dotfiles aduquette@localhost:~/.everc/

# SSH into VM to test
ssh -p 2222 aduquette@localhost
cd ~/.everc/dotfiles
./bootstrap.sh --profile rogue --dry-run
```

---

## Testing Progress

| Stage | Script | Dry-Run | Full Test | Notes |
|-------|--------|---------|-----------|-------|
| 0 | 00-preflight.sh | ✅ Pass | ⏳ | Detected Debian bullseye |
| 1 | 01-packages-core.sh | ✅ Pass | ⏳ | |
| 2 | 02-shell.sh | ✅ Pass | ⏳ | |
| 3 | 03-git-config.sh | ✅ Pass | ⏳ | |
| 4 | 04-packages-dev.sh | ✅ Pass | ⏳ | |
| 5 | 05-packages-desktop.sh | ✅ Pass | ⏳ | |
| 6 | 06-nvm.sh | ✅ Pass | ⏳ | |
| 7 | 07-docker.sh | ✅ Pass | ⏳ | |
| 8 | 08-apps-external.sh | ✅ Pass | ⏳ | |
| 9 | 09-dotfiles.sh | ✅ Pass | ⏳ | |
| 10 | 10-post-install.sh | ✅ Pass | ⏳ | |

---

## Next Steps

1. ~~**Fix bugs 1-5**~~ ✅ All fixed

2. ~~**Dry-run test**~~ ✅ Passed all 11 stages

3. **Full test run:**
   ```bash
   # Restore VM to "Fresh Install" snapshot first
   scp -r -P 2222 ~/.everc/dotfiles aduquette@localhost:~/.everc/
   ssh -p 2222 aduquette@localhost
   cd ~/.everc/dotfiles
   ./bootstrap.sh --profile rogue
   ```

4. **Verify idempotency:** Run bootstrap again - should skip completed stages

5. **Test stage resume:** Run with `--stage 5` to test resuming from specific stage

6. **Commit changes** when all tests pass

---

## Key Design Decisions (for reference)

- **Idempotency:** State tracked in `~/.everc/.setup-state`
- **Modular stages:** Each stage is a separate script for easy debugging
- **Profile support:** `--profile rogue|gomez|ts3d`
- **Resume capability:** `--stage N` resumes from stage N
- **Dry-run:** `--dry-run` should preview without changes
- **Auto-confirm:** `--yes` skips prompts for unattended install

---

## Files Modified for Bug Fixes

### Bug 1 - Remove curl from preflight ✅

**File:** `setup/00-preflight.sh` (line 49)

### Bug 2 - Fix dry-run in git-config ✅

**File:** `setup/03-git-config.sh` (lines 30, 60, 77)

---

## Original Requirements

- **Profile:** rogue (full Maverick build system)
- **Automation:** Fully automated with `--yes` flag
- **Idempotent:** Safe to re-run multiple times
- **Secrets:** None stored - generate on-site
- **Network:** Online available during setup
- **Target OS:** Debian 11 (Bullseye), also 12/13
