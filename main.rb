require "csv"
require_relative "./functions.rb"

@user_input = ARGV

@accounts = readCSV

priya = Account.new(:Priya, @accounts[:Priya])
priya.displayCSV
