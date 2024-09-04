To install this `R` package, first install the `devtools` package. Then type:

```
library(devtools)
devtools::install_github("cwolock/CFsurvival")
```

This fork of the original `CFsurvival` package allows users to choose between the `survSuperLearner` function from `survSuperLearner` and the `stackG` function from `survML` for estimating the conditional survival functions needed for `CFsurvival`. 
