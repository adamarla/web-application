
node(:transactions) {
  @transactions.map{ |t|
    {
      name: t.display,
      id: t.id,
      tag: t.quantity,
      badge: t.letter_code
    }
  }
}

