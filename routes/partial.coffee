module.exports = (req, res) ->  
  res.render 'partials/' + req.params[0]