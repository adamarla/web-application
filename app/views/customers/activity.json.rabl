
node(:activity) {
  @accounting_docs.map{ |a|
    {
      name: a.display,
      id: a.id,
      tag: a.balance,
      badge: a.open? ? "O" : "C"
    }
  }
}

