#!/bin/bash
USE_CLEAN_SUBENVS=1
echo "x${1:-}"
if [ "x${1:-}" == "x--no-clean-subenvs" ]; then
    #for CI where setup is slow (e.g. we have just painstakingly compiled
    #NCrystal). In that case, all dependencies of all notebooks must be already
    #available.
    USE_CLEAN_SUBENVS=0
fi
if [ "x$USE_CLEAN_SUBENVS" == "x1" ]; then
    echo "Running all notebooks. Will use clean sub-envs."
else
    echo "Running all notebooks. Will NOT use clean sub-envs."
fi

set -eu
export REPOROOT="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"
test -f "${REPOROOT}/README.md"
test -d "${REPOROOT}/notebooks"
DESTDIR="${REPOROOT}"/tmp_render_output
if [ -d "${DESTDIR}" ]; then
    echo "Removing existing ${DESTDIR}"
    rm -rf "${DESTDIR}"
fi
test ! -e "${DESTDIR}"

for notebookfile in `find "${REPOROOT}"/notebooks/ -name '*.ipynb'`; do
    echo
    echo '------------------------------------------------------'
    bn=$(basename "${notebookfile}")
    DESTFILE="${DESTDIR}/${bn}"
    if [ -e "${DESTFILE}" ]; then
        echo "Error: ${DESTFILE} already exists (notebook name clash detected)."
        exit 1
    fi
    echo "Removing existing ${DESTDIR}"

    echo "Testing ${bn}"
    #FIXME: Do something safer:
    WORK_DIR="${DESTDIR}/tmpworkdir_papermill_${RANDOM}${RANDOM}"
    rm -rf "${WORK_DIR}"
    mkdir -p "${WORK_DIR}"
    cd "${WORK_DIR}"
    cp ${notebookfile} ./nb.ipynb
    if [ "x$USE_CLEAN_SUBENVS" == "x1" ]; then
        if [[ -v VIRTUAL_ENV ]]; then
            type -t deactivate && deactivate
        fi
        python3 -mvenv create ./venv
        . ./venv/bin/activate
        thedeps="papermill ipython jupyter"
        echo "Pip installing ${thedeps} ..."
        python3 -mpip -q install ${thedeps}
        echo "...pip install done."
        mv ./nb.ipynb ./nb_orig.ipynb
        #FIXME: Do a grep that always_do_pip_installs = False exists!!
        #FIXME no pipes, do sed --inplace
        cat ./nb_orig.ipynb | \
            sed 's#always_do_pip_installs = False#always_do_pip_installs = True#' \
                > ./nb.ipynb


    fi
    mv ./nb.ipynb ./nb_unpruned.ipynb
    jupyter nbconvert --clear-output \
            --to notebook --output=./nb.ipynb nb_unpruned.ipynb
    papermill --cwd="${WORK_DIR}" \
              --progress-bar \
              --execution-timeout=10 \
              ./nb.ipynb \
              ./papermill_out.ipynb
    if [ "x$USE_CLEAN_SUBENVS" == "x1" ]; then
        deactivate
    fi
    mkdir -p "${DESTDIR}"
    cp ./papermill_out.ipynb "${DESTFILE}"
    echo "Produced ${DESTFILE}"
    cd "${DESTDIR}"
    rm -rf "${WORK_DIR}"
    #FIXME:
    #break
done
