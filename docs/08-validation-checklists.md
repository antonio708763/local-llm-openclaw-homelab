# Validation Checklists

## Windows post-resize

- [x] Windows boots normally
- [x] `chkdsk C: /scan` reports no problems
- [x] Important files and applications remain accessible
- [x] Archive drives are visible
- [x] `Dual_Boot_Share` appears as `H:`
- [x] Files can be created and read on `H:`

## Ubuntu storage

- [x] Ubuntu boots normally
- [x] `Dual_Boot_Share` appears in Files
- [x] UUID recorded as `48003BD2003BC62A`
- [x] Mounted at `/mnt/Dual_Boot_Share`
- [x] NTFS read/write access confirmed
- [x] Automatic mount confirmed after reboot
- [ ] Confirm cross-OS file compatibility with files created from both operating systems

## Ollama and model

- [x] NVIDIA driver working
- [x] CUDA access verified
- [x] RTX 4090 visible
- [x] Ollama installed, active, and enabled
- [x] `qwen3-coder:30b` downloaded
- [x] Coding response generated successfully
- [x] Model reported as `100% GPU`
- [x] OpenClaw `contextWindow` set to `32768`
- [x] Ollama `num_ctx` set to `32768`

## OpenClaw local validation

- [x] OpenClaw `2026.7.1-2` installed
- [x] Node.js `24.18.0` installed
- [x] OpenClaw resolves from `/home/antonio/.npm-global/bin/openclaw`
- [x] Workspace created at `~/.openclaw/workspace`
- [x] Ollama provider configured as local-only
- [x] Ollama URL set to `http://127.0.0.1:11434`
- [x] Default model set to `ollama/qwen3-coder:30b`
- [x] Gateway token authentication enabled
- [x] Gateway bound to `127.0.0.1:18789`
- [x] Gateway systemd user service enabled
- [x] Gateway runtime active and RPC probe `ok`
- [x] Ollama and Gateway auto-start confirmed after reboot
- [x] Forge identity completed
- [x] Semantic memory search disabled until a local provider is configured
- [x] Insecure Control UI authentication disabled
- [x] Cautious execution policy applied
- [x] Effective execution policy reports `security=allowlist` and `ask=on-miss`
- [x] Normal exec host set to `sandbox`
- [x] Compaction reserve set to `8192`
- [x] Compaction reserve floor set to `8192`
- [x] Recent-token retention set to `6000`
- [x] Configuration validates after compaction tuning
- [x] Detailed context breakdown inspected
- [x] `MEMORY.md` created and verified from Ubuntu
- [x] Dated memory note created and verified from Ubuntu
- [x] Current project checkpoint added to durable memory
- [x] Fresh session recalled durable goals, environment, and safety rules
- [x] Durable memory updated with the managed-browser milestone
- [x] `memory/2026-07-28.md` created and verified
- [x] Durable memory updated with the controlled-share milestone

## Docker validation

- [x] Docker installed from the official Docker repository
- [x] Docker Engine version `29.6.2`
- [x] Docker Compose version `v5.3.1`
- [x] Docker service enabled and active
- [x] `hello-world` completed successfully
- [x] Administrator added to Docker group
- [x] `docker ps` works without `sudo` after reboot

## OpenClaw command-sandbox validation

- [x] Image `openclaw-sandbox:bookworm-slim` built
- [x] Image includes Bash, curl, Git, jq, Python 3, ripgrep, and CA certificates
- [x] Container uses unprivileged `sandbox` user
- [x] Sandbox mode set to `all`
- [x] Backend set to `docker`
- [x] Scope set to `agent`
- [x] Workspace access set to `rw`
- [x] Docker network set to `bridge`
- [x] `sandbox explain` reports `runtime: sandboxed`
- [x] Host workspace maps to `/workspace`
- [x] First harmless tool request completed
- [x] Sandbox container appeared automatically
- [x] `openclaw sandbox list` reports one running runtime
- [x] Runtime image is `openclaw-sandbox:bookworm-slim`
- [x] Commands run as UID/GID `1000` user `sandbox`
- [x] Container reports Debian GNU/Linux 12
- [x] Working directory is `/workspace`
- [x] `/home/antonio` is not visible
- [x] Workspace file creation succeeded
- [x] Host saw the created file at `~/.openclaw/workspace/sandbox-test.txt`
- [x] Outbound DNS resolution succeeded
- [x] Outbound HTTPS returned HTTP 200

## Controlled shared-folder validation

- [x] Created `/mnt/Dual_Boot_Share/Forge_Shared`
- [x] Confirmed the parent NTFS partition is mounted read/write with `ntfs3`
- [x] Created and read `host-created.txt` from Ubuntu
- [x] Enabled `dangerouslyAllowExternalBindSources` deliberately
- [x] Command bind set exactly to `/mnt/Dual_Boot_Share/Forge_Shared:/forge-share:rw`
- [x] Browser bind list explicitly set to `[]`
- [x] Configuration validated after bind changes
- [x] Existing command sandbox removed and recreated on next use
- [x] Existing browser sandbox removed and recreated on next use
- [x] Forge read `/forge-share/host-created.txt`
- [x] Forge created `/forge-share/forge-created.txt`
- [x] Ubuntu confirmed `forge-created.txt` on the NTFS partition
- [x] Forge reported `PASS_ENTIRE_SHARE_HIDDEN`
- [x] Forge reported `PASS_HOST_HOME_HIDDEN`
- [x] Command-container mounts inspected directly
- [x] Command container has `/forge-share` read/write
- [x] Command container does not mount the entire `Dual_Boot_Share`
- [x] Browser-container mounts inspected directly
- [x] Browser container has no `/forge-share` mount
- [x] Browser container has no `Dual_Boot_Share` mount
- [x] Direct browser-container test reported `PASS: browser cannot see Forge_Shared`
- [x] Direct browser-container test reported `PASS: browser cannot see Dual_Boot_Share`
- [x] Managed browser still opened `https://example.com` successfully
- [x] Rollback commands documented

## Self-hosted search validation

- [x] OpenClaw SearXNG plugin installed
- [x] SearXNG container created with `--restart unless-stopped`
- [x] SearXNG published only on `127.0.0.1:8888`
- [x] HTML interface reachable locally
- [x] Persistent configuration mounted read-only from `~/searxng/settings.yml`
- [x] JSON output enabled
- [x] JSON search request returned results
- [x] OpenClaw search provider set to `searxng`
- [x] Plugin base URL set to `http://127.0.0.1:8888`
- [x] `web_search` and `web_fetch` added to sandbox tool policy
- [x] Fresh OpenClaw session exposed the `web_search` tool
- [x] Forge identified SearXNG as the provider
- [x] SearXNG container healthy at the stopping point
- [x] Plugin pinned to `@openclaw/searxng-plugin@2026.7.1`
- [x] Runtime inspection reports the exact pinned install specification

## Managed-browser validation

- [x] Browser plugin enabled
- [x] Browser control endpoint reachable
- [x] Matching OpenClaw source tag identified as `v2026.7.1`
- [x] Image `openclaw-sandbox-browser:bookworm-slim` built successfully
- [x] Browser sandbox enabled
- [x] Browser auto-start enabled
- [x] Browser image configured explicitly
- [x] Dedicated network configured as `openclaw-sandbox-browser`
- [x] Host-browser control disabled
- [x] noVNC enabled
- [x] `browser` added to global tool policy
- [x] `browser` added to sandbox tool policy
- [x] Configuration validated after browser changes
- [x] Gateway restarted after browser changes
- [x] Fresh session received the browser tool
- [x] Browser container created automatically
- [x] Browser container reports running status
- [x] Browser container uses `openclaw-sandbox-browser:bookworm-slim`
- [x] Browser container uses the dedicated network
- [x] `https://example.com` opened successfully
- [x] Final URL confirmed
- [x] Page title confirmed as `Example Domain`
- [x] Main heading confirmed as `Example Domain`
- [x] Browser snapshot completed
- [x] Browser screenshot completed
- [x] Screenshot files located under `~/.openclaw/media`
- [x] Browser mounts inspected
- [x] Personal Chrome profile not mounted
- [x] Personal Chromium profile not mounted
- [x] Personal Firefox profile not mounted
- [x] No credential or password-manager directory observed
- [x] `Dual_Boot_Share` not mounted into the browser container

## Security-audit validation

- [x] Deep audit rerun after browser configuration
- [x] Unpinned SearXNG warning resolved
- [x] Small-model-with-web-tools finding documented
- [x] Small-model finding accepted as residual risk for the current single-user sandboxed lab
- [x] Trusted-proxies warning reviewed
- [x] No trusted-proxy change made while the Gateway remains loopback-only
- [x] Browser use restricted away from banking, personal email, password managers, and sensitive administration
- [x] Web content designated as untrusted input

## Local evidence bundles

### Managed browser

- [x] `browser-config.json` created
- [x] `browser-image.txt` created
- [x] `browser-runtime.txt` created
- [x] `sandbox-tool-policy.json` created
- [x] `searxng-plugin.json` created
- [x] `security-audit.txt` created

### Controlled share

- [x] `browser-binds.json` created
- [x] `browser-container-mounts.txt` created
- [x] `command-binds.json` created
- [x] `command-container-mounts.txt` created
- [x] `host-verification.txt` created
- [x] `partition-mount.txt` created

### Evidence review

- [ ] Review every file for secrets before any public commit
- [ ] Commit only safe selected evidence artifacts

## Network readiness

- [x] Self-hosted SearXNG configured
- [x] Managed browser configured with deliberate permissions
- [x] Deep security audit rerun after browser setup
- [x] Controlled shared-folder access configured and validated
- [ ] Current network and firewall state inventoried
- [ ] Stable LAN address reserved
- [ ] Trusted LAN access configured
- [ ] Guest and IoT isolation verified
- [ ] NetBird deployment audited
- [ ] Remote access tested
- [ ] OpenClaw access boundaries implemented
