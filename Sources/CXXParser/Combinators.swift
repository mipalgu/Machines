
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
  let p = Parser<T> { _ in [] }
  return p
}

// The 'unit' combinator constructrs a Parser<T> from a T.
func unit<T>(t: T) -> Parser<T> {
  let p = Parser<T> { s in [(t, s)] }
}






