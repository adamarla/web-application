
node(:customers) {
  @customers.map { |c|
    :name => c.account.email,
    :id => c.id,
    :tag => c.currency,
    :badge => c.account.loggable == "School" ? c.cash_balance : c.credit_balance
  }
}
