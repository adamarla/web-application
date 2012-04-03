
###
  'plot' assumes that the passed JSON has atleast the following two keys 
  within json[key] - 'x' and 'y' and that the values for these are numbers (not strings)

  'consider' is a short call back function that looks at an individual JSON record
  and reports whether the record should be considered for plotting. The condition is 
  defined by us 
###


window.graphs = {
  getPlotPts: (json, key, consider = null) ->
    ret = []

    for d in json
      p = d[key]
      continue if consider? && consider(p) is false
      ret.push [p.x, p.y]
    return ret
}
