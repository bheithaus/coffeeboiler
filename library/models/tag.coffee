mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

tagSchema = new Schema
  name: 
    type: String
    unique: false

  creator:
    type: String
    required: true
    index:
      unique: false

  created: Date

module.exports = mongoose.model 'Tag', tagSchema