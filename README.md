# xiangshan_firrtl_reference_sv

Pre-emitted FIRRTL / SystemVerilog artifacts for the **bianco**
XiangShan Chisel → readable-SV translation project.

This repository is intentionally **not** the design source. It is a
cache of artifacts that any developer can regenerate from
[`bianco`](https://github.com/davideschiavone/bianco) on a machine
with enough RAM (~12 GB free). Carrying them in a separate repo
keeps `bianco` itself lean and lets its CI run on memory-constrained
hosted runners (GitHub Actions standard runners have only 7 GB RAM,
which is not enough for the XiangShan elaboration + firtool pipeline
to run simultaneously).

## Layout

```
xiangshan_firrtl_reference_sv/
├── README.md                       # this file
├── scripts/
│   └── regenerate.sh               # one-shot regen + populate from bianco
├── reference_sv/                   # firtool-emitted SV (one file per FIRRTL module)
│   ├── *.sv                        # 1875 main modules
│   ├── verification/               # difftest probe binds (BIANCO_DIFFTEST-gated)
│   └── filelist.f
├── build/wrappers/
│   └── *_wrapper.sv                # 553 wrappergen.py-emitted pack/unpack wrappers
└── docs/
    └── sibling_groups.json         # group_siblings.py inferred parameter table
```

## What's NOT included

* `build/firrtl/XSTop.fir` — single 865 MB file, over GitHub's
  100 MB per-file git limit. It's an intermediate that `wrappergen.py`
  needs only for **typed-bundle** mode and only during regeneration.
  CI doesn't need it because the wrappers themselves are committed
  here. Developers regenerate it locally on demand via `make reference`.

## Consumed by

[`bianco`](https://github.com/davideschiavone/bianco) at `add_ci`+
adds this repo as a git submodule under `firrtl_artifacts/` and
symlinks the three top-level paths into the expected bianco locations:

```
bianco/reference_sv             → firrtl_artifacts/reference_sv
bianco/build/wrappers           → firrtl_artifacts/build/wrappers
bianco/docs/sibling_groups.json → firrtl_artifacts/docs/sibling_groups.json
```

After cloning bianco, run:

```bash
git submodule update --init --recursive
```

and the symlinks resolve.

## Regeneration

Whenever any of these change:

* `bianco/XiangShan` submodule pointer moves (new XiangShan commit)
* `bianco/scripts/wrappergen.py` changes
* `bianco/scripts/group_siblings.py` changes
* `bianco/docs/translation_registry.json` adds variants / renames classes
* `bianco/readable_sv/*.sv` adds new files that need new wrappers
* `bianco/scripts/emit_firrtl_reference.sh` changes

the contents of this repo are stale. Regenerate with:

```bash
# In a checkout of bianco where you've run setup.sh and have at
# least 12 GB free RAM:
cd /path/to/bianco
source ~/.bianco_env
make reference           # ~10 min: firtool emit → reference_sv/ + build/firrtl/XSTop.fir
make wrappers            # ~30 s: wrappergen.py → build/wrappers/

# Then in a checkout of THIS repo (one level up from bianco, e.g.):
cd /path/to/xiangshan_firrtl_reference_sv
bash scripts/regenerate.sh /path/to/bianco
# The script rsyncs reference_sv/, build/wrappers/, docs/sibling_groups.json
# from the given bianco path, then `git add -A`.

# Inspect the diff, commit, push:
git status
git diff --stat
git add -A
git commit -m "regenerate artifacts at <bianco-sha>"
git push

# Finally, bump bianco's submodule pointer:
cd /path/to/bianco
git submodule update --remote firrtl_artifacts
git add firrtl_artifacts
git commit -m "bump firrtl_artifacts submodule"
git push
```

## Licence

The contents are derived from
[OpenXiangShan/XiangShan](https://github.com/OpenXiangShan/XiangShan)
which is Apache 2.0. The same licence applies here.
