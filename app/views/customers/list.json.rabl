object false
  node(:customers) {
    @customers.map{ |c|
      {
        name: c.account.loggable.name,
        id: c.id,
        tag: c.currency,
        badge: c.account.loggable == "Student" ? c.credit_balance : c.cash_balance
      }
    }
  }
