# Contributing

This is a personal project maintained by [ozzy-labs](https://github.com/ozzy-labs). External contributions are not currently accepted.

## Bug Reports & Feature Requests

If you find a bug or have an idea for improvement, please open an issue.

## Testing

### Non-interactive mode

Set either environment variable to skip interactive prompts (useful in CI / Docker):

```bash
WSL_DEV_SETUP_ASSUME_YES=1 ./install.sh local    # explicit opt-in
CI=true ./install.sh local                        # auto-enabled in most CI systems
```

Behavior:

- `[Y/n]` prompts → auto `Y` (install)
- `[y/N]` prompts (Azure CLI / Google Cloud CLI / non-Ubuntu confirmation) → auto `N` (skip / abort)
- Git username/email: pre-configure via `git config --global user.{name,email}` beforehand to land on the "already configured" code path

### Local test execution

```bash
# L0: Smoke tests (~500ms, no network)
./tests/smoke/run.sh

# L2: BATS unit tests
mise exec -- bats tests/unit/

# L3: Docker integration tests (~5-10 min per version)
./tests/integration/run.sh                 # default: ubuntu:24.04
./tests/integration/run.sh 22.04 24.04     # multiple versions
./tests/integration/run.sh devel           # canary (next Ubuntu)
```

`tests/integration/run.sh` picks up `GITHUB_TOKEN` from either your environment
or `gh auth token` (if `gh` is installed). Forwarding it to the container raises
mise's GitHub API rate limit from 60 to 5000 requests/hour, which matters when
running the full suite multiple times in short succession.

### CI (GitHub Actions)

| Workflow | Trigger | What it does |
|---|---|---|
| `lint.yaml` | PR + main push | shellcheck / shfmt / markdownlint / yamllint / gitleaks |
| `test-smoke.yaml` | PR + main push | Runs `tests/smoke/run.sh` (no Docker) |
| `test-unit.yaml` | PR + main push | Runs BATS suite via `mise` |
| `test-integration.yaml` | main push, manual, or PR labeled `ci:integration` | Runs `tests/integration/run.sh` against 22.04 + 24.04 in matrix |

Integration tests are opt-in for PRs (~5 min/version) to keep feedback fast on code-only changes. Add the `ci:integration` label when changing `scripts/setup-local-ubuntu.sh` or `tests/integration/`.

### WSL2 pre-release smoke checklist

Docker covers Ubuntu userspace but cannot reproduce WSL2 specifics (systemd, `wslu`, Windows interop). Before cutting a release, verify on a fresh WSL2/Ubuntu environment:

- [ ] `install.sh zsh` completes; a new terminal has `echo $SHELL` pointing at zsh
- [ ] `install.sh local` completes; `mise --version` / `node --version` / `pnpm --version` / `python3 --version` / `uv --version` / `gitleaks version` all work
- [ ] `install.sh update` completes without error on an already-installed system
- [ ] `wslview https://example.com` opens the Windows default browser
- [ ] `sudo service docker start` succeeds, `docker run --rm hello-world` prints the welcome message
- [ ] `echo $LANG` returns `ja_JP.UTF-8`; `date` prints JST
- [ ] `git config --global user.name` / `user.email` are set as expected
- [ ] AI CLI auth flows (`claude auth login`, `codex auth login`, `copilot`, `gemini`) start correctly

### Suggested branch protection (repo owners)

- Require PR review before merge into `main`
- Require the following status checks: `lint`, `test-smoke`, `test-unit`
- Leave `test-integration` optional; gate it via the `ci:integration` label or trust main-push runs

## License

By interacting with this project, you agree that any contributions you make will be licensed under the [MIT License](LICENSE).
