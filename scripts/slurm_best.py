#!/usr/bin/env python3
"""
slurm_best.py — One-SSH-call Slurm probe for Greene (NYU), tolerant GPU-family matching.

- Batches all Slurm queries in ONE SSH call (no repeated logins).
- Matches GPU families using aliases and fallbacks:
    1) GRES token (e.g., gpu:rtx8000:1, gpu:rtx:1, gpu:1)
    2) Node features (%f), e.g., 'rtx', 'v100', 'a100', 'h100'
    3) Partition name contains a family hint (e.g., 'rtx')
- Prints ALL eligible account/partition candidates per GPU family, then Top-K with rationales.
- Shows a 'Match' basis (gres:/feature:/part:), so you know why it was selected.
- If GRES type is unknown but features match, example uses --gres=gpu:<N> and --constraint=<feature>.

Defaults:
  SSH      : ah7660@greene.hpc.nyu.edu
  Job shape: --gpus 1 --cpus 4 --mem 16 (GB) --minutes 120
  Output   : --top 3
  Matching : --match-mode lenient  (use --match-mode strict to require explicit tokens like 'rtx8000')

Usage:
  ./slurm_best.py
  ./slurm_best.py --gpus 2 --cpus 8 --mem 32 --minutes 90 --top 3
  ./slurm_best.py --match-mode strict
  ./slurm_best.py --ssh-timeout 45
"""

import argparse, os, re, shlex, subprocess, sys
from collections import defaultdict, Counter
from typing import Dict, List, Optional, Tuple

DEFAULT_SSH_HOST = "greene.hpc.nyu.edu"
DEFAULT_SSH_USER = "ah7660"
GPU_FAMILIES = ["rtx8000", "v100", "a100", "h100"]

# ----- UI helpers -----

def supports_color() -> bool:
    return sys.stdout.isatty() and os.environ.get("TERM","") != "dumb"

class C:
    if supports_color():
        BOLD="\033[1m"; DIM="\033[2m"; GRN="\033[32m"; YLW="\033[33m"; RST="\033[0m"
    else:
        BOLD=DIM=GRN=YLW=RST=""

def pad(s, n): s=str(s); return s + " " * max(0, n-len(s))
def gb_to_mb(gb: int) -> int: return int(gb) * 1024

def human_dur_to_minutes(s: str) -> Optional[int]:
    s = (s or "").strip().lower()
    if not s or s == "infinite": return None
    m = re.match(r"(?:(\d+)-)?(\d{1,2}):(\d{2})(?::(\d{2}))?$", s)
    if m:
        d=int(m.group(1) or 0); h=int(m.group(2) or 0); mm=int(m.group(3) or 0); ss=int(m.group(4) or 0)
        return d*24*60 + h*60 + mm + (1 if ss>0 else 0)
    return int(s) if s.isdigit() else None

# ----- ONE SSH CALL -----

SECTION_TAG = "<<<SECTION"
END_TAG = "<<<END>>>"

def run_one_ssh(ssh_host: str, ssh_user: str, timeout_s: int) -> Dict[str, List[str]]:
    dest = f"{ssh_user}@{ssh_host}" if ssh_user else ssh_host
    remote_script = r"""
set -euo pipefail

print_section() {
  echo "<<<SECTION $1>>>"
  shift
  if command -v "$1" >/dev/null 2>&1; then
    "$@"
  fi
}

echo "<<<SECTION user>>>"
id -un 2>/dev/null || true

print_section sshare    sshare   -u "$(id -un 2>/dev/null || echo "")" -l -P -o Account,User,EffectvUsage,FairShare
print_section sacctmgr  sacctmgr -n -P show assoc where user="$(id -un 2>/dev/null || echo "")" format=Account,Partition

# Node matrix: add %f (features) to help when GRES type is missing or generic
print_section sinfo_nodes  sinfo -Nh -o %P^%T^%c^%m^%G^%f
print_section sinfo_limits sinfo -h  -o %P^%l
print_section squeue_pd    squeue -h -t PD -o %P

echo "<<<END>>>"
""".strip()

    ssh_cmd = [
        "ssh","-o","BatchMode=yes","-o","ConnectTimeout=12","-o","ServerAliveInterval=10",
        dest, "bash","-lc", shlex.quote(remote_script)
    ]
    try:
        out = subprocess.check_output(ssh_cmd, stderr=subprocess.STDOUT, text=True, timeout=timeout_s)
    except subprocess.TimeoutExpired:
        raise SystemExit(f"{C.YLW}Timeout:{C.RST} SSH probe exceeded {timeout_s}s. "
                         f"Increase --ssh-timeout or complete MFA promptly.")
    except subprocess.CalledProcessError as e:
        msg = e.output.strip() if e.output else "(no output)"
        raise SystemExit(f"{C.YLW}SSH error:{C.RST} {msg}")

    sections: Dict[str, List[str]] = {}
    current = None
    for line in out.splitlines():
        if line.startswith(END_TAG): break
        if line.startswith(SECTION_TAG):
            m = re.match(r"<<<SECTION\s+([a-zA-Z0-9_]+)>>>\s*$", line)
            current = m.group(1) if m else None
            if current: sections[current] = []
            continue
        if current: sections[current].append(line.rstrip("\n"))
    return sections

# ----- parsing -----

def parse_sshare(lines: List[str], user: str) -> Dict[str, Dict[str, float]]:
    if not lines: return {}
    hdr = lines[0].split("|"); col = {name: i for i, name in enumerate(hdr)}
    out: Dict[str, Dict[str, float]] = {}
    for row in lines[1:]:
        parts = row.split("|")
        if len(parts) != len(hdr): continue
        if parts[col.get("User",-1)] != user: continue
        acc = parts[col["Account"]]
        try: fs = float(parts[col["FairShare"]]); fs = max(0.0, min(1.0, fs))
        except: fs = 0.0
        try: eu = float(parts[col["EffectvUsage"]]); eu = max(0.0, eu)
        except: eu = 0.0
        out[acc] = {"FairShare": fs, "EffectvUsage": eu}
    return out

def parse_assocs(lines: List[str]) -> Dict[str, set]:
    out: Dict[str, set] = defaultdict(set)
    for row in lines:
        parts = row.split("|")
        if len(parts) < 2: continue
        acc, part = parts[0].strip(), parts[1].strip()
        if not acc or not part: continue
        for p in part.split(","):
            p = p.strip()
            if p: out[acc].add(p)
    return dict(out)

def parse_sinfo_nodes(lines: List[str]):
    """
    sinfo -Nh -o %P^%T^%c^%m^%G^%f
    Returns list: {partition, state, cpus, mem_mb, gpus{token->count}, features:set(str)}
    """
    nodes = []
    for row in lines:
        parts = (row.split("^") + ["","","","",""])[:6]
        part = parts[0].strip().rstrip("*")
        state = parts[1].strip().upper()
        try: cpus = int(parts[2].strip())
        except: cpus = 0
        try: mem_mb = int(parts[3].strip())
        except: mem_mb = 0
        gres = parts[4].strip().lower()
        feats_raw = (parts[5] or "").strip().lower()
        # Parse GRES; allow typed (gpu:rtx8000:4) and generic (gpu:4)
        gpu_map = defaultdict(int)
        if gres:
            for item in gres.split(","):
                item = item.strip()
                m = re.match(r"gpu:([^:,\(\)]+):(\d+)", item)
                if m:
                    gpu_map[m.group(1)] += int(m.group(2)); continue
                m2 = re.match(r"gpu:(\d+)$", item)
                if m2:
                    gpu_map["gpu"] += int(m2.group(1)); continue
        # Parse features into tokens
        feats = set([t for t in re.split(r"[,\s]+", feats_raw) if t])
        nodes.append({"partition": part, "state": state, "cpus": cpus, "mem_mb": mem_mb,
                      "gpus": dict(gpu_map), "features": feats})
    return nodes

def parse_sinfo_limits(lines: List[str]) -> Dict[str, Optional[int]]:
    out: Dict[str, Optional[int]] = {}
    for row in lines:
        p, lim = (row.split("^") + ["",""])[:2]
        out[p.strip().rstrip("*")] = human_dur_to_minutes((lim or "").strip())
    return out

def parse_squeue_pd(lines: List[str]) -> Dict[str, int]:
    counts = Counter()
    for row in lines:
        p = row.strip().rstrip("*")
        if p: counts[p] += 1
    return dict(counts)

# ----- matching -----

ALIASES = {
    # For RTX8000: allow 'rtx8000' and generic 'rtx' (lenient). Strict requires explicit 8000.
    "rtx8000": {
        "strict": [r"\brtx-?8000\b"],
        "lenient": [r"\brtx-?8000\b", r"\brtx\b"],
    },
    "v100": {
        "strict":  [r"\bv100\b", r"\btesla-?v100\b"],
        "lenient": [r"\bv100\b", r"\btesla-?v100\b", r"\bvolta\b"],
    },
    "a100": {
        "strict":  [r"\ba100\b"],
        "lenient": [r"\ba100\b"],
    },
    "h100": {
        "strict":  [r"\bh100\b"],
        "lenient": [r"\bh100\b", r"\bhopper\b"],
    },
}

def _match_patterns(text: str, patterns: List[str]) -> Optional[str]:
    for pat in patterns:
        if re.search(pat, text):
            return pat
    return None

def classify_match(partition: str, node: dict, family: str, mode: str):
    """
    Returns (matched: bool, specificity: float, basis: str, gres_token: Optional[str], feature_token: Optional[str])
    basis ∈ {'gres:<tok>', 'feature:<tok>', 'part:<substr>'}
    Specificity: 1.00 exact token (e.g., rtx8000), 0.85 alias (e.g., rtx), 0.70 feature, 0.60 partition-name hint.
    """
    patterns = ALIASES.get(family, {}).get(mode, [])
    # 1) GRES typed token
    for tok in node["gpus"].keys():
        if tok == "gpu":  # generic; check later
            continue
        if _match_patterns(tok, patterns):
            # exact vs alias specificity
            spec = 1.00 if re.search(r"\b" + re.escape(family) + r"\b", tok) else 0.85
            return True, spec, f"gres:{tok}", tok, None
    # 2) Features
    for ft in node["features"]:
        if _match_patterns(ft, patterns):
            spec = 0.70 if ft != family else 0.90
            return True, spec, f"feature:{ft}", None, ft
    # 3) Partition name
    if _match_patterns(partition, patterns):
        return True, 0.60, f"part:{partition}", None, None
    # 4) Generic GRES only counts if we had a feature/partition hint (handled above).
    return False, 0.0, "", None, None

def idle_fraction(states: Counter) -> float:
    tot = sum(states.values())
    return (states.get("IDLE",0) / tot) if tot>0 else 0.0

def headroom(pending_jobs: int, eligible_nodes: int) -> float:
    if eligible_nodes <= 0: return 0.0
    return 1.0 / (1.0 + pending_jobs / eligible_nodes)

def backfill_bonus(maxwall_min: Optional[int], assumed_minutes: int) -> float:
    if maxwall_min is None: return 0.4
    gap = abs(maxwall_min - assumed_minutes)
    if gap <= 60: return 1.0
    if gap <=120: return 0.8
    if gap <=240: return 0.6
    if gap <=480: return 0.4
    return 0.2

# ----- core -----

def build_candidates(user: str, sshare_lines, assoc_lines, nodes, lims, pend,
                     req_gpus, req_cpus, req_mem_gb, assumed_minutes, match_mode: str):
    acc2fs = parse_sshare(sshare_lines, user)
    acc2parts = parse_assocs(assoc_lines)
    part2nodes = defaultdict(list)
    for n in nodes:
        part2nodes[n["partition"]].append(n)

    # If associations are unavailable, assume all visible partitions are allowed.
    if not acc2parts:
        all_parts = set(part2nodes.keys())
        if acc2fs:
            acc2parts = {acc: set(all_parts) for acc in acc2fs}
        else:
            acc2fs = {"<no-sshare>": {"FairShare": 0.5, "EffectvUsage": 0.0}}
            acc2parts = {"<no-sshare>": set(all_parts)}

    req_mem_mb = gb_to_mb(req_mem_gb)
    all_rows_by_gpu: Dict[str, List[Tuple[float, str, str, dict, dict]]] = {}

    for fam in GPU_FAMILIES:
        rows = []
        for acc, parts in acc2parts.items():
            fs = float(acc2fs.get(acc, {}).get("FairShare", 0.5))
            for part in parts:
                pnodes = part2nodes.get(part, [])
                if not pnodes: continue

                eligible = []
                matches_basis = []
                best_token_for_example = None
                best_feature_for_example = None

                for nd in pnodes:
                    # Does this node look like the requested family?
                    matched, spec, basis, gres_tok, feat_tok = classify_match(part, nd, fam, match_mode)
                    if not matched:
                        continue
                    # Check capacity (GPUs/CPUs/Mem)
                    # If GRES typed token exists, enforce count on that token.
                    # If we matched via feature/partition and only have generic 'gpu', enforce count on generic.
                    gpu_count = 0
                    if gres_tok and gres_tok in nd["gpus"]:
                        gpu_count = nd["gpus"].get(gres_tok, 0)
                    elif "gpu" in nd["gpus"]:
                        gpu_count = nd["gpus"]["gpu"]
                    else:
                        # No visible GRES count; conservatively skip
                        continue
                    if gpu_count < req_gpus: continue
                    if nd["cpus"] < req_cpus: continue
                    if nd["mem_mb"] and nd["mem_mb"] < req_mem_mb: continue

                    eligible.append(nd)
                    matches_basis.append((spec, basis))
                    # Track example tokens by highest specificity
                    if gres_tok:
                        if (best_token_for_example is None) or (spec > best_token_for_example[0]):
                            best_token_for_example = (spec, gres_tok)
                    elif feat_tok:
                        if (best_feature_for_example is None) or (spec > (best_feature_for_example[0] if isinstance(best_feature_for_example, tuple) else 0)):
                            best_feature_for_example = (spec, feat_tok)

                if not eligible:
                    continue

                states = Counter(nd["state"] for nd in eligible)
                idle = idle_fraction(states)
                head = headroom(pend.get(part, 0), len(eligible))
                back = backfill_bonus(lims.get(part), assumed_minutes)

                # Small nudge for more specific matches (exact token > alias > feature > partition)
                specificity_bonus = 0.0
                if matches_basis:
                    top_spec = max(spec for spec, _ in matches_basis)
                    specificity_bonus = 0.03 * top_spec   # max ≈ +0.03

                score = 0.45*idle + 0.30*fs + 0.15*back + 0.10*head + specificity_bonus

                if best_token_for_example:
                    match_str = max(matches_basis)[1]  # basis with highest specificity
                    example_mode = ("gres", best_token_for_example[1])
                elif best_feature_for_example:
                    match_str = max(matches_basis)[1]
                    example_mode = ("feature", best_feature_for_example[1])
                else:
                    # fallback to first basis string
                    match_str = matches_basis[0][1]
                    example_mode = ("generic", None)

                metrics = {
                    "score": round(score,3),
                    "idle_fraction": round(idle,3),
                    "fairshare": round(fs,3),
                    "queue_headroom": round(head,3),
                    "backfill": round(back,3),
                }
                counts = {
                    "eligible_nodes": len(eligible),
                    "pending_jobs": pend.get(part, 0),
                    "example_mode": example_mode,   # ('gres', 'rtx8000') or ('feature','rtx') or ('generic', None)
                    "match_basis": match_str,       # e.g., 'gres:rtx8000', 'feature:rtx', 'part:cs-rtx'
                }
                rows.append((score, acc, part, metrics, counts))
        rows.sort(key=lambda x: x[0], reverse=True)
        all_rows_by_gpu[fam.upper()] = rows

    return all_rows_by_gpu

# ----- reporting -----

def print_report(all_rows_by_gpu, assumed_minutes, req_gpus, req_cpus, req_mem_gb, topk):
    print(f"\n{C.BOLD}Best account/partition by GPU type "
          f"(assumed walltime ≈ {assumed_minutes} min | req: {req_gpus}xGPU, {req_cpus} CPU, {req_mem_gb} GB){C.RST}\n")
    for fam, rows in all_rows_by_gpu.items():
        print(f"{C.BOLD}{fam}{C.RST}")
        if not rows:
            print(f"  {C.DIM}(No eligible partitions meet the requested resources for this GPU family){C.RST}\n")
            continue

        # ALL candidates
        header = ["Rank","Account","Partition","Score","Idle","FairShare","QueueHead","Backf.","Elig","Pend","Match"]
        #              0      1         2         3       4       5           6           7       8      9      10
        colw   = [     6,    24,       22,       6,      9,      10,         11,          8,     8,     8,     20]
        print("  " + " | ".join(pad(h, colw[i]) for i,h in enumerate(header)))
        print("  " + "-"*(sum(colw)+3*len(colw)-1))

        for i, (_, acc, part, m, c) in enumerate(rows, start=1):
            line = [
                pad(i, colw[0]),
                pad(acc, colw[1]),
                pad(part, colw[2]),
                pad(f"{m['score']:.3f}", colw[3]),
                pad(f"{m['idle_fraction']:.3f}", colw[4]),
                pad(f"{m['fairshare']:.3f}", colw[5]),
                pad(f"{m['queue_headroom']:.3f}", colw[6]),
                pad(f"{m['backfill']:.3f}", colw[7]),
                pad(c['eligible_nodes'], colw[8]),
                pad(c['pending_jobs'], colw[9]),
                pad(c['match_basis'], colw[10]),
            ]
            print("  " + " | ".join(str(x) for x in line))
        print()

        # Top-K
        K = min(topk, len(rows))
        if K:
            print(f"  Top {K} recommendations")
            for r in range(K):
                _, acc, part, m, c = rows[r]
                why = (f"     Why: idle={m['idle_fraction']:.2f}, fairshare={m['fairshare']:.2f}, "
                       f"queue_headroom={m['queue_headroom']:.2f}, backfill={m['backfill']:.2f}; "
                       f"eligible_nodes={c['eligible_nodes']}, pending={c['pending_jobs']}, match={c['match_basis']}")
                hh = assumed_minutes // 60
                mm = assumed_minutes % 60
                time_str = f"{hh:02d}:{mm:02d}:00"
                mode, token = c["example_mode"]
                if mode == "gres":
                    gres_part = f"--gres=gpu:{token}:{req_gpus}"; extra = ""
                elif mode == "feature" and token:
                    gres_part = f"--gres=gpu:{req_gpus}";        extra = f" --constraint={token}"
                else:
                    gres_part = f"--gres=gpu:{req_gpus}";        extra = ""
                ex = (f"     e.g., sbatch -A {acc} -p {part} {gres_part}{extra} "
                      f"-c {req_cpus} --mem={req_mem_gb}G --time={time_str} run.sh")
                print(f"  {r+1}) {acc} / {part}\n{why}\n{C.DIM}{ex}{C.RST}\n")
        print()


# ----- main -----

def main():
    ap = argparse.ArgumentParser(description="Find best Slurm account/partition per GPU family (one SSH call, tolerant matching).")
    ap.add_argument("--ssh-host", default=DEFAULT_SSH_HOST, help=f"SSH host (default: {DEFAULT_SSH_HOST})")
    ap.add_argument("--ssh-user", default=DEFAULT_SSH_USER, help=f"SSH user (default: {DEFAULT_SSH_USER})")
    ap.add_argument("--ssh-timeout", type=int, default=35, help="Overall SSH call timeout in seconds (default: 35)")
    ap.add_argument("--gpus", type=int, default=1, help="GPUs required per job (default: 1)")
    ap.add_argument("--cpus", type=int, default=4, help="CPUs required (default: 4)")
    ap.add_argument("--mem", type=int, default=16, help="Memory in GB (default: 16)")
    ap.add_argument("--minutes", type=int, default=120, help="Assumed walltime in minutes (default: 120)")
    ap.add_argument("--top", type=int, default=3, help="Show top-K per GPU family (default: 3)")
    ap.add_argument("--match-mode", choices=["strict","lenient"], default="lenient",
                    help="Family matching mode. 'strict' requires explicit types (e.g., rtx8000). 'lenient' also accepts generic tokens like 'rtx'.")
    args = ap.parse_args()

    sections = run_one_ssh(args.ssh_host, args.ssh_user, args.ssh_timeout)
    user = (sections.get("user") or [""])[0].strip()

    sshare_lines = sections.get("sshare", [])
    assoc_lines  = sections.get("sacctmgr", [])
    nodes        = parse_sinfo_nodes(sections.get("sinfo_nodes", []))
    lims         = parse_sinfo_limits(sections.get("sinfo_limits", []))
    pend         = parse_squeue_pd(sections.get("squeue_pd", []))

    results = build_candidates(
        user=user,
        sshare_lines=sshare_lines,
        assoc_lines=assoc_lines,
        nodes=nodes,
        lims=lims,
        pend=pend,
        req_gpus=args.gpus,
        req_cpus=args.cpus,
        req_mem_gb=args.mem,
        assumed_minutes=args.minutes,
        match_mode=args.match_mode,
    )
    print_report(results, args.minutes, args.gpus, args.cpus, args.mem, args.top)

if __name__ == "__main__":
    main()
