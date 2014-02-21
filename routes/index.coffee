module.exports =
  partial: require './partial'

  index: (req, res) ->
    res.render 'index', { 
      title: 'Express'
      user: req.user
    }

