## Test environments

release 4.1.1

* OSX (local) - release
* OSX (actions) - release
* Ubuntu (actions) - 3.6, oldrel, release and devel
* Windows (actions) - release
* Windows (winbuilder) - devel

## R CMD check results

0 errors | 0 warnings | 0 notes

## CRAN Package Check Results

> We fixed all CRAN Package Check Results except for the ERROR on r-release-macos-arm64 (https://www.r-project.org/nosvn/R.check/r-release-macos-arm64/sims-00check.html) which is due to the rjags Package Check ERROR (https://cran.r-project.org/web/checks/check_results_rjags.html).

But that is precisely the issue:

You have rjags in Suggests, hence the package must pass the checks even if the suggested (rjags) package or its SytstemRequirements are unavailable.
Please only run such code conditionally on the availability of the *weak* dependencies.

Please fix and resubmit.

DONE!
