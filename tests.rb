require_relative "./functions.rb"

def test_equality(actual, expected)
  if actual == expected
    puts "Pass!"
  else
    puts "Fail! Expected #{expected} but got #{actual}."
  end
end

bob = Account.new(:Bob, {
  snacks: [-100.00, -50.25, -10.37, -25.00, -47.89],
  tea: [-23.00, -150.50, -67.35]})

# Test 1

snack_total = bob.category_total(:snacks)
tea_total = bob.category_total(:tea)

test_equality(snack_total, -233.51)
test_equality(tea_total, -240.85)

# Test 2

snack_average = bob.category_average(:snacks)
tea_average = bob.category_average(:tea)

test_equality(snack_average, -46.70)
test_equality(tea_average, -80.28)

# Test 3

balance = bob.account_balance()

test_equality(balance, -474.36)
