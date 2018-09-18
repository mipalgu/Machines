import Functional

func item() -> Parser<Character> {
  return Parser {s in
    if let (c, cs) = uncons(s) {
      return (c, String(cs))
    }
    else {
      return nil
    }
  }
}

func satisfy(_ pred: @escaping (Character) -> Bool) -> Parser<Character> {
  return (item() >>- {c in
    return pred(c) ? pure(c) : empty()
  })
}

func oneOf(_ l: String) -> Parser<Character> {
  return satisfy(l.contains)
}


