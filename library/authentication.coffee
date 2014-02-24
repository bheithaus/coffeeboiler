async = require 'async'
utils = require 'lodash'
jwt = require 'jsonwebtoken'
User = require('./models').user

class registerValidations
  constructor: (user, callback) ->
    # validations
    operations =
      password_confirm: (done) =>
        validationError = if user.password == user.password_confirm
        then null
        else 'confirmation must match password'

        done null, validationError 

      password: (done) =>
        validationError = if user.password.length >= 3
        then null
        else 'password must be 3 or more characters'

        done null, validationError

      email: (done) =>
        User.findOne { email: user.email }, (error, user) ->
          return done error if error
          validationError = if not user
          then null
          else 'that email is already taken'

          done null, validationError 

      name: (done) =>
        User.findOne { name: user.name }, (error, user) ->
          return done error if error
          validationError = if not user then null else 'that name is already taken'
        
          done null, validationError

    async.parallel operations, (error, results) -> 
      for key, val of results
        delete results[key] if !val

      callback error, results

loginUser = (user, res) ->
  profile =
    name: user.name
    email: user.email
    id: user._id

  token = jwt.sign profile, config.JWT_Token, { expiresInMinutes: 60*5 }

  res.json 
    token: token

module.exports =
  register: (req, res) ->
    user = req.body

    new registerValidations user, (error, validationErrors) ->
      # if errors
      return res.json { errors: validationErrors } if Object.keys(validationErrors).length

      # remove confirmation
      delete user.password_confirm

      User.create user, (error, user) ->
        loginUser(user, res)

  session: (req, res) ->
    return res.send 401 if not req.user
    res.json req.user

  login: (req, res, next) ->
    User.findOne { name: req.body.name }, (err, user) -> 
      console.log user
      if err or not user
        return res.json 400, { error: 'name / password dont match' }
    
      user.comparePassword req.body.password, (error, valid) ->
        if not valid
          res.json 400, { error: 'name / password dont match' }
        else
          loginUser(user, res)


  logout: (req, res) ->
    res.json { ok: true }

    