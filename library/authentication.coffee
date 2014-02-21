LocalStrategy = require('passport-local').Strategy
passport = require 'passport'
async = require 'async'
utils = require 'lodash'
jwt = require 'jsonwebtoken'
User = require('./models').user

class registerValidations
  constructor: (form, callback) ->
    # validations
    operations =
      passwordConfirmation: (done) =>
        validationError = if form.password[0] == form.password[1]
        then null
        else 'confirmation must match password'

        done null, validationError 

      password: (done) =>
        validationError = if form.password[0].length >= 3
        then null
        else 'password must be 3 or more characters'

        done null, validationError

      email: (done) =>
        User.findOne { email: form.email }, (error, user) ->
          return done error if error
          validationError = if not user
          then null
          else 'that email is already taken'

          done null, validationError 

      name: (done) =>
        User.findOne { name: form.name }, (error, user) ->
          return done error if error
          validationError = if not user then null else 'that name is already taken'
        
          done null, validationError

    async.parallel operations, (error, results) -> 
      for key, val of results
        delete results[key] if !val

      callback error, results

module.exports =
  register: (req, res) ->
    user = req.body
    new registerValidations user, (error, validationErrors) ->
      console.error error if error
      console.log 'validationErrors', validationErrors
      # if errors
      return res.json validationErrors if Object.keys(validationErrors).length

      # remove confirmation
      user.password = user.password[0]

      User.create user, (error, user) ->
        console.error error if error
        console.log 'user created! - ', user

        req.login user, (error) ->
          console.error error if error
          res.redirect '/' 

  session: (req, res) ->
    return res.send 401 if not req.user
    res.json req.user

  login: (req, res, next) ->
    User.findOne { name: req.body.name }, (err, user) -> 
      console.log 'in auth', user, err         
      if err or not user
        return res.json 400, { error: 'name / password dont match' }
    
      user.comparePassword req.body.password, (error, valid) ->
        if not valid
          res.json 400, { error: 'name / password dont match' }
        else
          profile =
            name: user.name
            email: user.email
            id: user._id

          token = jwt.sign profile, config.JWT_Token, { expiresInMinutes: 60*5 }

          res.json 
            token: token

  logout: (req, res) ->
    req.logout()
    res.json { ok: true }

  # initial setup of Passport Auth
  setup: (app) ->
    app.use passport.initialize()
    app.use passport.session()

    # passport session setup
    passport.serializeUser (user, done) ->
      done null, user.id

    passport.deserializeUser (id, done) ->
      User.findById id, (err, user) ->
        cleaned = 
          name: user.name
          email: user.email
          id: user._id

        done err, cleaned
      
    passport.use(new LocalStrategy({ usernameField: 'name' },
      (username, password, done) ->
        User.findOne { name: username }, (err, user) ->          
          if err
            return done err

          if not user
            return done null, false, { message: 'Incorrect username.' } 
        
          user.comparePassword password, (error, valid) ->
            if not valid
              done null, false, { message: 'Incorrect password.' }
            else 
             done null, user
    ))