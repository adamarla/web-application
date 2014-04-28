
node(:transactions) {
  @transactions.map{ |t|
    {
      name: t.display,
      id: t.id,
      tag: t.quantity
    }
  }
}

