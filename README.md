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
├── reference_sv/             # 1875 firtool-emitted SV files (~230 MB)
│   ├── *.sv                  # main modules
│   ├── verification/         # BIANCO_DIFFTEST-gated probe binds
│   └── filelist.f
└── build/firrtl/
    └── XSTop.fir.xz          # FIRRTL intermediate, xz-compressed (~15 MB)
                              # decompresses to ~865 MB; CI runs `xz -d`
                              # on submodule init. Needed by wrappergen's
                              # typed-bundle mode to parse Chisel Bundle
                              # definitions.
```

## What's NOT here (and why)

* **`build/wrappers/`** — output of bianco's `scripts/wrappergen.py`,
  which evolves frequently as new translation features land.
  Regenerated in bianco's CI on every run from `reference_sv/` +
  the bianco-side registry.
* **`docs/sibling_groups.json`** — output of bianco's
  `scripts/group_siblings.py`. Same reasoning: regenerated in CI.
* **`build/firrtl/XSTop.fir` (raw, uncompressed)** — 865 MB
  uncompressed; we ship `XSTop.fir.xz` (~15 MB, ~57× xz compression
  on firtool's repetitive text) instead. CI decompresses on submodule
  init via `xz -dk`. Allows wrappergen's typed-bundle mode to work
  in CI without LFS or release-asset complexity.
* **`scripts/regenerate.sh`** — folded into bianco's Makefile as
  `make regen-artifacts` (depends on `make reference`, then
  xz-compresses the .fir into this repo). Keeps the regen pipeline
  in sync with bianco's source.

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
# In your bianco checkout (firrtl_artifacts submodule already inited):
cd /path/to/bianco
source ~/.bianco_env
make regen-artifacts         # ~10 min: firtool emit + xz the .fir

# That target:
#  1. runs `make reference` (writes reference_sv/ through the symlink
#     into firrtl_artifacts/reference_sv/, produces build/firrtl/XSTop.fir)
#  2. xz-compresses XSTop.fir → firrtl_artifacts/build/firrtl/XSTop.fir.xz
#
# Inspect, commit, push the artifact repo:
cd firrtl_artifacts
git status
git add -A
git commit -m "regenerate at bianco $(cd .. && git rev-parse --short HEAD)"
git push
```

Then bump bianco's submodule pointer:

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
