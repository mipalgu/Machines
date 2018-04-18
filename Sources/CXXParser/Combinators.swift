infix operator <|>: AdditionPrecedence


// The Parser datatype 
struct Parser<T> {
  let parse: (String) -> [(T, String)]
}

// The 'run' function applies Parser p to String s and returns an optional T if 
// successful or nil otherwise.
func run<T>(p: Parser<T>, s: String) -> T? {
  return nil
}

// The 'between' function checks for the sequential occurance of
// start p end. That is, that parser p is between parser start and parser end.
func between<T, U, V>(start: Parser<T>, end: Parser<U>, p: Parser<V>) 
  -> Parser<V>? {
  return nil
}

// The 'failure' combinator returns an empty Parser.
func failure<T>() -> Parser<T> {
  return Parser<T> { _ in [] }
}

// The '<|>' operator tries to first parse p, if p fails, it tries to parse q.
func <|> <T>(p: Parser<T>, q: Parser<T>) -> Parser<T> {
  return Parser<T> {s in
    let r = p.parse(s)
    return r.isEmpty ? q.parse(s) : r
  }
}

// The 'some' function applies the Parser p one or more times in succession.
// On failure it terminates.
func some<T>(p: Parser<T>) -> Parser<[T]> {
  var xs = []
  func f(s: String) -> [(T, String)] {
    let r = p.parse(s)
    if let (a, s') = r.first {
      f(s')
    }
  }
}

// The 'pure' combinator constructs a Parser<T> from a T.
func pure<T>(t: T) -> Parser<T> {
  return Parser<T> { s in [(t, s)] }
}



// func bind<T, U>(p: Parser<T>, f: T -> Parser<U>) -> Parser<U> {
//   need concatMap to go farther.
// }






