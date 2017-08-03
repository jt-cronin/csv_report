require "csv"
require "pry"
require_relative "./functions.rb"

@user_input = ARGV

@accounts = {}

CSV.foreach("accounts.txt", {headers: true, return_headers: false}) do |row|
  @accounts[row["Account"].chomp.to_sym] = {}
end

CSV.foreach("accounts.txt", {headers: true, return_headers: false}) do |row|
  @accounts[row["Account"].chomp.to_sym][row["Category"].chomp.to_sym] = []
end

CSV.foreach("accounts.txt", {headers: true, return_headers: false}) do |row|
  account = row["Account"].chomp.to_sym
  category = row["Category"].chomp.to_sym
  outflow = -row["Outflow"][1..-1].to_f
  inflow = row["Inflow"][1..-1].to_f
  inflow == 0 ? @accounts[account][category] << outflow : @accounts[account][category] << inflow
end

def categoryTotal(account, category, total = 0)
  @accounts[account][category].each { |amount| total += amount }
  total.round(2)
end

def categoryAverage(account, category)
  (categoryTotal(account, category) / @accounts[account][category].length).round(2)
end

def calcBalance(account, balance = 0)
  @accounts[account].each { |category, transaction| transaction.each { |amount| balance += amount } }
  balance.round(2)
end

def displayAccountCSV account
  if !@accounts.include? account
    puts "Error: Unknown Account"
    return
  end
  puts "Account: #{account}... Balance: $#{calcBalance(account)}"
  puts "Category".ljust(20) + "Total Spent".ljust(20) + "Average Transaction"
  @accounts[account].each do |category, transaction|
    puts category.to_s.ljust(20) + "$" + categoryTotal(account, category).to_s.ljust(20) + "$" + categoryAverage(account, category).to_s.ljust(20)
  end
  nil
end

def displayAccountHTML account
    if !@accounts.include? account
      puts "Error: Unknown Account"
      return
    end
    puts "<h1>#{account.to_s}</h1>\n<p>Total Balance: $#{calcBalance(account)}</p>\n<hr>\n<table>\n  <tr>\n    <th>Category</th>\n    <th>Total Spent</th>\n    <th>Avg. Transaction</th>\n  </tr>\n\n"
    @accounts[account].each do |category, transaction|
      puts "  <tr>\n    <td>#{category}</td>\n    <td>$#{categoryTotal(account,category).to_s}</td>\n    <td>$#{categoryAverage(account,category).to_s}</td>\n  </tr>"
    end
    puts "</table>"
end

displayAccountCSV(@user_input[0].to_sym) if (@user_input.length == 1 || @user_input[1] == "csv")
displayAccountHTML(@user_input[0].to_sym) if (@user_input[1] == "html")
