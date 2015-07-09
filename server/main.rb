#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'data_mapper'

DB_PATH = File.join(__dir__, '../db.sqlite')


DataMapper::Logger.new($stdout, :debug)
#DataMapper.setup(:default, 'sqlite::memory:')
DataMapper.setup(:default, 'sqlite://' + DB_PATH)

require_relative 'models.rb'

DataMapper.finalize()
DataMapper.auto_migrate!() # WARN: This drops and recreates tables!

require_relative 'seed.rb'
require_relative 'views.rb'
