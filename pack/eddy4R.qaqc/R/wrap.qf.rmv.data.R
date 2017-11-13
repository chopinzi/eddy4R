##############################################################################################
#' @title Definition function: to remove high frequency data points that have failed quality flags

#' @author 
#' Dave Durden \email{ddurden@battelleecology.org}

#' @description 
#' Definition function  to remove high frequency data points that have failed quality flags from a data.frame
#' @param inpList List consisting of \code{ff::ffdf} file-backed objects, in the format provided by function \code{eddy4R.base::wrap.neon.read.hdf5.eddy()}. Of types numeric and integer.
#' @param Vrbs Optional. A logical {FALSE/TRUE} value indicating whether to:\cr
#' \code{Vrbs = FALSE}: (Default) cleaned data set with the bad high frequency quality flagged data replaced with NaN's as part of the \code{inpList} in the same format., or \cr
#' \code{Vrbs = TRUE}: cleaned data set with the bad high frequency quality flagged data replaced with NaN's as part of the \code{inpList} in the same format. In addition, a separate list  \code{qfqmAnal} will be added to the output list \code{rpt} with a list of variables assessed, a list of quality flags for each variable assessed, the number of each quality flag tripped for each variable and the total number of bad data per variable.
#' 
#' @return The returned object consistes of \code{inpList}, with the bad high frequency quality flagged data replaced with NaN's. Optionally, (\code{Vrbs = TRUE}) a separate list \code{qfqmAnal} will be added to the output list \code{rpt} with a list of variables assessed, a list of quality flags for each variable assessed, the number of each quality flag tripped for each variable and the total number of bad data per variable.

#' @references 
#' License: GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007. \cr
#' NEON Algorithm Theoretical Basis Document:Eddy Covariance Turbulent Exchange Subsystem Level 0 to Level 0’ data product conversions and calculations (NEON.DOC.000807) \cr
#' Licor LI7200 reference manual

#' @keywords NEON, qfqm, quality

#' @examples 
#' Currently none

#' @seealso Currently none

#' @export

# changelog and author contributions / copyrights
#   Dave Durden (2017-10-27)
#     original creation
##############################################################################################


wrap.qf.rmv.data <- function(inpList, Vrbs = FALSE){
  
  #Initialize reporting list
  rpt <- inpList
  
  #Determine the sensors that have data and quality flags
  sens <- intersect(names(inpList$data), names(inpList$qfqm))
  
  #test <- def.qf.rmv.data(dfData = inpList$data[[var[2]]], dfQf = inpList$qfqm[[var[2]]], Sens = var[2])
  # Determine quality flags to apply to each stream, quantify flags, and remove bad data across all sensors
  outList <- lapply(sens, function(x){ eddy4R.qaqc::def.qf.rmv.data(dfData = inpList$data[[x]][], inpList$qfqm[[x]], Sens = x, Vrbs = Vrbs)
  })
  
  #Apply names to the output list
  names(outList) <- sens
  
  #Applying the bad quality flags to the reported output data
  lapply(names(outList), function(x) {
    rpt$data[[x]] <<- as.ffdf(outList[[x]]$dfData) 
  })
  
  if(Vrbs == TRUE){
    lapply(names(outList), function(x) {
    rpt$qfqmAnal[[x]] <<- outList[[x]][!names(outList[[x]]) %in% "dfData"] 
  })}
  
  #Return the list of information with bad data removed
  return(rpt)
}