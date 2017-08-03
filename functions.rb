class Account
  def initialize(name, transactions)
    @name = name
    @transactions = transactions
  end

  def category_total(category)
    total = 0
    @transactions[category].each { |amount| total += amount }
    total.round(2)
  end

  def category_average(category)
    (self.category_total(category) / @transactions[category].length).round(2)
  end

  def account_balance
    balance = 0
    @transactions.each { |category, amounts| balance += category_total(category) }
    balance.round(2)
  end

  def displayCSV
    puts "Account: #{@name}... Balance: $#{self.account_balance}"
    puts "Category".ljust(20) + "Total Spent".ljust(20) + "Average Transaction"
    @transactions.each do |category, amounts|
      puts category.to_s.ljust(20) + "$" + self.category_total(category).to_s.ljust(20) + "$" + self.category_average(category).to_s.ljust(20)
    end
    nil
  end

  def displayHTML
    puts "<h1>#{@name}</h1>\n<p>Total Balance: $#{self.account_balance}</p>\n<hr>\n<table>\n  <tr>\n    <th>Category</th>\n    <th>Total Spent</th>\n    <th>Avg. Transaction</th>\n  </tr>\n\n"
    @transactions.each do |category, amounts|
      puts "  <tr>\n    <td>#{category}</td>\n    <td>$#{self.category_total(category).to_s}</td>\n    <td>$#{self.category_average(category).to_s}</td>\n  </tr>"
    end
    puts "</table>"
  end
end

def getNames accounts
  CSV.foreach("accounts.txt", {headers: true, return_headers: false}) do |row|
    accounts[row["Account"].chomp.to_sym] = {}
  end
  accounts
end

def getCategories accounts
  CSV.foreach("accounts.txt", {headers: true, return_headers: false}) do |row|
    accounts[row["Account"].chomp.to_sym][row["Category"].chomp.to_sym] = []
  end
  accounts
end

def getTransactions accounts
  CSV.foreach("accounts.txt", {headers: true, return_headers: false}) do |row|
    account = row["Account"].chomp.to_sym
    category = row["Category"].chomp.to_sym
    outflow = -row["Outflow"][1..-1].to_f
    inflow = row["Inflow"][1..-1].to_f
    accounts[account][category] << outflow + inflow
  end
  accounts
end

def readCSV
  accounts = {}
  getTransactions(getCategories(getNames(accounts)))
  accounts
end
