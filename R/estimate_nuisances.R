.estimate.conditional.survival.stackG <- function(Y, Delta, A, W, newW, fit.times, fit.treat, stackG.control, cens.trunc, save.fit) {
  ret <- list(fit.times=fit.times)
  AW <- cbind(A, W)
  if(0 %in% fit.treat & 1 %in% fit.treat) {
    newAW <- rbind(cbind(A=0, newW), cbind(A=1, newW))
  } else {
    newAW <- cbind(A=fit.treat, newW)
  }
  res <- require(survML)
  if(!res) stop("Please install the package survML via:\n install.packages('survML')")
  if(is.null(stackG.control)) stackG.control <- list(bin_size = 0.05, 
                                                     time_basis = "continuous", 
                                                     SL_control = list(SL.library = c("SL.mean", "SL.glm", "SL.gam", "SL.earth", "SL.ranger", "SL.xgboost"),
                                                                       V = 5,
                                                                       method = "method.NNLS",
                                                                       stratifyCV = FALSE))
  
  fit <- stackG(time = Y, 
                event = Delta, 
                X = AW, 
                newX = newAW, 
                newtimes = fit.times, 
                bin_size = stackG.control$bin_size, 
                time_basis = stackG.control$time_basis, 
                SL_control = stackG.control$SL_control)
  if(save.fit) ret$surv.fit <- fit
  if(0 %in% fit.treat) {
    ret$event.pred.0 <- fit$S_T_preds[1:nrow(newW),]
    if(any(ret$event.pred.0 == 0)) ret$event.pred.0[ret$event.pred.0 == 0] <- min(ret$event.pred.0[ret$event.pred.0 > 0])
    ret$cens.pred.0 <- fit$S_C_preds[1:nrow(newW),]
    ret$cens.pred.0 <- pmax(ret$cens.pred.0, cens.trunc)
    if(any(ret$cens.pred.0 == 0)) ret$cens.pred.0[ret$cens.pred.0 == 0] <- min(ret$cens.pred.0[ret$cens.pred.0 > 0])
    if(1 %in% fit.treat) {
      ret$event.pred.1 <- fit$S_T_preds[-(1:nrow(newW)),]
      if(any(ret$event.pred.1 == 0)) ret$event.pred.1[ret$event.pred.1 == 0] <- min(ret$event.pred.1[ret$event.pred.1 > 0])
      
      ret$cens.pred.1 <- fit$S_C_preds[-(1:nrow(newW)),]
      ret$cens.pred.1 <- pmax(ret$cens.pred.1, cens.trunc)
      if(any(ret$cens.pred.1 == 0)) ret$cens.pred.1[ret$cens.pred.1 == 0] <- min(ret$cens.pred.1[ret$cens.pred.1 > 0])
    }
  } else {
    ret$event.pred.1 <- fit$S_T_preds
    if(any(ret$event.pred.1 == 0)) ret$event.pred.1[ret$event.pred.1 == 0] <- min(ret$event.pred.1[ret$event.pred.1 > 0])
    ret$cens.pred.1 <- fit$S_C_preds
    ret$cens.pred.1 <- pmax(ret$cens.pred.1, cens.trunc)
    if(any(ret$cens.pred.1 == 0)) ret$cens.pred.1[ret$cens.pred.1 == 0] <- min(ret$cens.pred.1[ret$cens.pred.1 > 0])
  }
  ret$event.coef <- NULL
  ret$cens.coef <- NULL
  return(ret)
}

.estimate.conditional.survival.survSL <- function(Y, Delta, A, W, newW, fit.times, fit.treat, event.SL.library, cens.SL.library, survSL.control, survSL.cvControl, cens.trunc, verbose, save.fit) {
    ret <- list(fit.times=fit.times)
    AW <- cbind(A, W)
    if(0 %in% fit.treat & 1 %in% fit.treat) {
        newAW <- rbind(cbind(A=0, newW), cbind(A=1, newW))
    } else {
        newAW <- cbind(A=fit.treat, newW)
    }
    res <- require(survSuperLearner)
    if(!res) stop("Please install the package survSuperLearner via:\n devtools::install_github('tedwestling/survSuperLearner')")
    if(is.null(survSL.control)) survSL.control <- list(saveFitLibrary = save.fit)

    fit <- survSuperLearner(time = Y, event = Delta,  X = AW, newX = newAW, new.times = fit.times, event.SL.library = event.SL.library, cens.SL.library = cens.SL.library, verbose=verbose, control = survSL.control, cvControl = survSL.cvControl)
    if(save.fit) ret$surv.fit <- fit
    if(0 %in% fit.treat) {
        ret$event.pred.0 <- fit$event.SL.predict[1:nrow(newW),]
        if(any(ret$event.pred.0 == 0)) ret$event.pred.0[ret$event.pred.0 == 0] <- min(ret$event.pred.0[ret$event.pred.0 > 0])
        ret$cens.pred.0 <- fit$cens.SL.predict[1:nrow(newW),]
        ret$cens.pred.0 <- pmax(ret$cens.pred.0, cens.trunc)
        if(any(ret$cens.pred.0 == 0)) ret$cens.pred.0[ret$cens.pred.0 == 0] <- min(ret$cens.pred.0[ret$cens.pred.0 > 0])
        if(1 %in% fit.treat) {
            ret$event.pred.1 <- fit$event.SL.predict[-(1:nrow(newW)),]
            if(any(ret$event.pred.1 == 0)) ret$event.pred.1[ret$event.pred.1 == 0] <- min(ret$event.pred.1[ret$event.pred.1 > 0])

            ret$cens.pred.1 <- fit$cens.SL.predict[-(1:nrow(newW)),]
            ret$cens.pred.1 <- pmax(ret$cens.pred.1, cens.trunc)
            if(any(ret$cens.pred.1 == 0)) ret$cens.pred.1[ret$cens.pred.1 == 0] <- min(ret$cens.pred.1[ret$cens.pred.1 > 0])
        }
    } else {
        ret$event.pred.1 <- fit$event.SL.predict
        if(any(ret$event.pred.1 == 0)) ret$event.pred.1[ret$event.pred.1 == 0] <- min(ret$event.pred.1[ret$event.pred.1 > 0])
        ret$cens.pred.1 <- fit$cens.SL.predict
        ret$cens.pred.1 <- pmax(ret$cens.pred.1, cens.trunc)
        if(any(ret$cens.pred.1 == 0)) ret$cens.pred.1[ret$cens.pred.1 == 0] <- min(ret$cens.pred.1[ret$cens.pred.1 > 0])
    }
    ret$event.coef <- fit$event.coef
    ret$cens.coef <- fit$cens.coef
    return(ret)
}

.estimate.propensity <- function(A, W, newW, SL.library, fit.treat, prop.trunc, save.fit, verbose) {
    ret <- list()
    library(SuperLearner)
    if (length(SL.library) == 1) {
        if(length(unlist(SL.library)) == 2 & ncol(W) > 1) {
            screen <- get(SL.library[[1]][2])
            whichScreen <- screen(Y = A, X = W, family = 'binomial')
        } else {
            whichScreen <- rep(TRUE, ncol(W))
        }
        learner <- get(SL.library[[1]][1])
        prop.fit <- learner(Y = A, X = W[,whichScreen, drop=FALSE], newX = newW[,whichScreen, drop=FALSE], family='binomial')
        ret$prop.pred <- prop.fit$pred
        if(save.fit) {
            ret$prop.fit <- list(whichScreen = whichScreen, pred.alg = prop.fit)
        }
    } else {
        prop.fit <- SuperLearner(Y=A, X=W, newX=newW, family='binomial',
                                 SL.library=SL.library, method = "method.NNloglik", verbose = verbose)
        ret$prop.pred <- c(prop.fit$SL.predict)
        if(save.fit) ret$prop.fit <- prop.fit
    }
    if(1 %in% fit.treat) ret$prop.pred <- pmax(ret$prop.pred, prop.trunc)
    if(0 %in% fit.treat) ret$prop.pred <- pmin(ret$prop.pred, 1-prop.trunc)
    return(ret)
}
