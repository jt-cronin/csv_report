require "csv"
require "pry"
require "fileutils"
require_relative "./functions.rb"

@raw_account_data = readCSV

def getAction
  puts "\nPlease select one of the following actions:\n  Show existing accounts (enter 'show')\n  Create a new account (enter 'create')\n  Display data for an existing account (enter 'display')\n  Update an existing account (enter 'update')\n  Delete account (enter 'delete')\n  Exit the program (enter 'exit')"
  print "=>"; action = gets.chomp
  while !%w{show create display update delete exit}.include? action
    puts "\nInvalid command. Please try again."
    print "=>"; action = gets.chomp
    puts
  end
  case action
  when 'show'
    showExistingAccounts
  when 'create'
    createNewAccount
  when 'display'
    displayExistingAccount
  when 'update'
    updateAccount
  when 'delete'
    deleteAccount
  when 'exit'
    exit
  end
end

def showExistingAccounts
  @raw_account_data.each_key { |key| puts key }
  getAction
end

def createNewAccount
  puts "\nEnter the name of the new account:"
  print "=>"; name = gets.chomp.to_sym
  while @raw_account_data.has_key? name
    puts "\nThat's already an existing account. Please try again."
    print "=>"; name = gets.chomp.to_sym
  end
  puts "\nPlease enter a starting balance: (e.g. 50.25)"
  print "=>"; balance = gets.chomp
  while balance.to_f < 0 or !balance.scan(/[^0-9.]/).empty?
    puts "\nInvalid balance. Please try again."
    print "=>"; balance = gets.chomp
  end
  balance = balance.to_f.round(2)
  date = Time.new.strftime("%m/%d/%Y")
  File.open('accounts.txt', 'a') do |line|
    line.puts "#{name},#{date},STARTING BALANCE,Allowance,$0.00,$#{balance}"
  end
  @raw_account_data = readCSV
  getAction
end

def displayExistingAccount
  puts "\nEnter an account name:"
  print "=>"; name = gets.chomp.to_sym
  while !@raw_account_data.has_key? name
    puts "\nThat's not an existing account. Please try again."
    print "=>"; name = gets.chomp.to_sym
  end
  account = Account.new(name, @raw_account_data[name])
  puts "\nEnter a display format (enter 'csv' or 'html')"
  print "=>"; display_format = gets.chomp
  while !(['csv','html'].include? display_format)
    puts "\nThat's not a correct format. Please try again."
    print "=>"; display_format = gets.chomp
  end
  display_format == 'csv' ? account.displayCSV : account.displayHTML
  getAction
end

def updateAccount
  puts "\nEnter an account name:"
  print "=>"; name = gets.chomp
  while !@raw_account_data.has_key? name.to_sym
    puts "\nThat's not an existing account. Please try again."
    print "=>"; name = gets.chomp
  end
  account = Account.new(name.to_sym, @raw_account_data[name.to_sym])
  puts "\nHere's your current account data:"
  account.displayCSV
  puts "\nEnter a category:"
  print "=>"; category = gets.chomp
  confirmed = account.transactions.has_key? category.to_sym
  while !confirmed
    puts "Not an existing category. Still continue? y/n"
    if gets.chomp == "y"
      confirmed = true
    else
      puts "\nEnter a category:"
      print "=>"; category = gets.chomp
      confirmed = account.transactions.has_key? category.to_sym
    end
  end
  puts "Is this inflow or outflow? (enter 'inflow' or 'outflow')"
  print "=>"; transaction_type = gets.chomp
  while !['inflow','outflow'].include? transaction_type
    puts "Not a valid transaction type. Try again."
    print "=>"; transaction_type = gets.chomp
  end
  puts "\nPlease enter an amount: (e.g. 50.25)"
  print "=>"; amount = gets.chomp
  while amount.to_f < 0 or !amount.scan(/[^0-9.]/).empty?
    puts "\nInvalid amount. Please try again."
    print "=>"; amount = gets.chomp
  end
  inflow = transaction_type == 'inflow' ? amount.to_f.round(2) : 0.00
  outflow = transaction_type == 'outflow' ? amount.to_f.round(2) : 0.00
  date = Time.new.strftime("%m/%d/%Y")
  puts "\nPlease enter a payee:"
  print "=>"; payee = gets.chomp
  File.open('accounts.txt', 'a') do |line|
    line.puts "#{name},#{date},#{payee},#{category},$#{outflow},$#{inflow}"
  end
  @raw_account_data = readCSV
  getAction
end

def deleteAccount
  puts "\nEnter an account name:"
  print "=>"; name = gets.chomp
  while !@raw_account_data.has_key? name.to_sym
    puts "\nThat's not an existing account. Please try again."
    print "=>"; name = gets.chomp
  end
  puts "WARNING: Changes cannot be undone! Continue? (y/n)"
  getAction if gets.chomp != "y"
  open('accounts.txt', 'r') do |f|
    open('temp.txt', 'w') do |f2|
      f.each do |line|
        f2.write(line) unless line.start_with? name
      end
    end
  end
  FileUtils.mv 'temp.txt', 'accounts.txt'
  @raw_account_data = readCSV
  getAction
end

getAction
