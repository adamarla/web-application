
###
  'plot' assumes that the passed JSON has atleast the following two keys 
  within json[key] - 'x' and 'y' and that the values for these are numbers (not strings)

  'consider' is a short call back function that looks at an individual JSON record
  and reports whether the record should be considered for plotting. The condition is 
  defined by us 
###


window.graphs = {
  getPlotPts: (json, key, xCorrection = null, consider = null) ->
    ret = []

    for d in json
      p = d[key]
      continue if consider? && consider(p) is false
      if xCorrection?
        xbar = p.x - xCorrection
        ret.push([xbar, p.y], [0, p.y], null)
      else
        xbar = p.x
        ret.push([xbar, p.y])
       
    return ret
}
