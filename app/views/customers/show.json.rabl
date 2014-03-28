object false
  node(:customer) {
    name: customer.account.email,
    balance: "#{customer.credit_balance} Gredits and #{customer.cash_balance} #{customer.currency}"
  }
