# Restore all test-only resource limits when the test session ends.
withr::local_options(list(readr.num_threads = 2L, mc.cores = 2L),
  .local_envir = testthat::teardown_env()
)
withr::local_envvar(
  c(
    VROOM_THREADS = "2", OMP_NUM_THREADS = "2",
    OPENBLAS_NUM_THREADS = "2", MKL_NUM_THREADS = "2"
  ),
  .local_envir = testthat::teardown_env()
)
