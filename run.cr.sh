echo "

UNOPTIMIZED MODE:

" > run.cr.out

time crystal github_repo_version_stats.cr >> run.cr.out 2>&1

echo "

RELEASE MODE:

" >> run.cr.out

crystal build --release github_repo_version_stats.cr
time ./github_repo_version_stats >> run.cr.out 2>&1
