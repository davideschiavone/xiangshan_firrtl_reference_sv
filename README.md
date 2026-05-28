# xiangshan_firrtl_reference_sv

Pre-emitted FIRRTL → SystemVerilog reference, used as a git submodule
by the [`bianco`](https://github.com/davideschiavone/bianco) XiangShan
Chisel → readable-SV translation project.

## What's here

Only the **raw firtool output** — the artifacts whose content depends
purely on the XiangShan source and firtool version, NOT on bianco's
scripts:

```
xiangshan_firrtl_reference_sv/
├── README.md
└── reference_sv/             # 1875 firtool-emitted SV files (~230 MB)
    ├── *.sv                  # main modules
    ├── verification/         # BIANCO_DIFFTEST-gated probe binds
    └── filelist.f
```

## What's NOT here (and why)

* **`build/wrappers/`** — output of bianco's `scripts/wrappergen.py`,
  which evolves frequently as new translation features land.
  Regenerated in bianco's CI on every run from `reference_sv/` +
  the bianco-side registry.
* **`docs/sibling_groups.json`** — output of bianco's
  `scripts/group_siblings.py`. Same reasoning: regenerated in CI.
* **`build/firrtl/XSTop.fir`** — 865 MB intermediate, over GitHub's
  100 MB per-file git limit. Only needed for typed-bundle wrappergen
  (currently 2 classes in bianco's registry, with their wrappers
  committed in bianco directly). Regenerated locally on demand.
* **`scripts/regenerate.sh`** — moved to
  [`bianco/scripts/regenerate_firrtl_artifacts.sh`](https://github.com/davideschiavone/bianco/blob/main/scripts/regenerate_firrtl_artifacts.sh)
  so it stays in sync with bianco's emit pipeline.

Keeping the artifact repo this thin means it only needs a new commit
when **XiangShan moves** (the firtool input changes) — bianco-side
script churn no longer requires bumping this repo.

## Consumed by

bianco adds this repo as a git submodule at `firrtl_artifacts/` and
symlinks the reference path into the expected bianco location:

```
bianco/reference_sv → firrtl_artifacts/reference_sv
```

After cloning bianco:

```bash
git submodule update --init --recursive
```

and the symlink resolves.

## Regeneration

The artifact repo's content becomes stale only when XiangShan moves.
Regenerate from a roomy machine (~12 GB free RAM, ~10 min wall time):

```bash
# In your bianco checkout:
cd /path/to/bianco
source ~/.bianco_env
make reference               # ~10 min: firtool emit, writes reference_sv/

# Sync into the artifact repo + commit + push:
bash scripts/regenerate_firrtl_artifacts.sh /path/to/this/clone
```

That script handles the rsync + pinning the bianco SHA in
`.bianco-source-sha`. Then you bump bianco's submodule pointer:

```bash
cd /path/to/bianco
git submodule update --remote firrtl_artifacts
git add firrtl_artifacts
git commit -m "bump firrtl_artifacts: <reason>"
git push
```

## Licence

The contents are derived from
[OpenXiangShan/XiangShan](https://github.com/OpenXiangShan/XiangShan)
which is Apache 2.0. The same licence applies here.
