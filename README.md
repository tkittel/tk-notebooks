# tk-notebooks
Testing repo for mctools/ncrystal-notebooks infrastructure

## For users of NCrystal who wants to access the notebooks:

Users should go to https://some/where to view the actual documentation!

## For contributers and developers of these notebooks:

First of all, if the instructions below are confusing or you are just a casual contributer, feel free to simply open a github issue HERE and attach the notebook (.ipynb) file you wish to contribute.

You can edit .ipynb files as normal using for instance a local jupyter-lab instance. However, **AND THIS IS IMPORTANT**, before committing any notebooks, please **ALWAYS** run `./devel/cleanup_notebooks.x` to ensure no huge output cells gets added by mistake to the Git history of this repository. This should be done even if you interactively cleared all output cells before saving, since it also ensures other jupyter metadata gets formatted in a consistent manner (for more meaningful `git diff`'s).

For minor changes you can always just use a testing branch or PR to verify that everything runs OK in the github actions CI, before the changes are accepted in the main branch (and thus are deployed to the website).

For larger changes (like when adding a completely new notebook), you should test the notebooks are rendered and the website is built correctly. You can check the rendering by:

./devel/render_notebooks.x

(this will place temporary output in `./tmp_render_output`).

And you can build and view the website locally by:

./devel/bld_doc.x
