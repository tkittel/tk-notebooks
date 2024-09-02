#!/bin/bash
set -eu
export REPOROOT="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"
test -f "${REPOROOT}"/README.md
test -d "${REPOROOT}"/notebooks/
find "${REPOROOT}"/notebooks/ -name '*.ipynb' -exec nbstripout --drop-empty-cells {} +
