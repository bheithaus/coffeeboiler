mongoose = require 'mongoose'
bcrypt = require 'bcrypt'
Schema = mongoose.Schema
SALT_WORK_FACTOR = 10

UserSchema = new Schema
  name:
    type: String
    required: true
    index:
      unique: true

  email:
    type: String
    required: true
    index:
      unique: true

  password:
    type: String
    required: true

UserSchema.pre 'save', (next) ->
  # only hash the password if it has been modified (or is new)
  return next() if not @isModified('password')

  # generate a salt
  bcrypt.genSalt SALT_WORK_FACTOR, (error, salt) =>
    return next error if error

    # hash the password along with our new salt
    bcrypt.hash @password, salt, (error, hash) =>
      return next error if error

      # override the cleartext password with the hashed one
      @password = hash
      next()

UserSchema.methods.comparePassword = (candidatePassword, cb) ->
  bcrypt.compare candidatePassword, @password, (error, isMatch) ->
    return cb error if error
    cb null, isMatch

module.exports = mongoose.model 'User', UserSchema