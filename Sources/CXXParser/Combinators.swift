import Functional

/**
 * The Parser structure.
 *
 * A Parser is just a wrapper around a parse function: `String -> (T, String)?`
 */
struct Parser<T> {
  
  let parse: (String) -> (T, String)?
}

func id<T>(_ t: T) -> T {
  return t
}

func const<T, U>(_ t: T) -> (U) -> T {
  return { _ in t }
}

// The 'pure' combinator lifts a T up into a Parser<T>.
func pure<T>(_ t: T) -> Parser<T> {
  return Parser { s in (t, s) }
}

// The 'empty' combinator represents a blank or failed Parser.
func empty<T>() -> Parser<T> {
  return Parser { _ in nil }
}

// pronounced "bind". The '>>-' function allows sequential chaining of parsers.
func >>- <T, U>(_ p: Parser<T>, _ f: @escaping (T) -> Parser<U>) -> Parser<U> {
  return Parser {s in
    if let (a, s2) = p.parse(s) {
      return f(a).parse(s2)
    }
    else {
      return nil
    }
  }
}

// pronounced "fmap". The '<^>' function allows transformations of parsers T to
// parsers U, given a function T -> U.
func <^> <T, U>(_ f: @escaping (T) -> U, p: Parser<T>) -> Parser<U> {
  return p >>- { s in pure(f(s)) }
}

// pronounced "alternative". The '<|>' function attempts parser p, and if it
// fails, then attempts parser q.
func <|> <T>(_ p: Parser<T>, _ q: Parser<T>) -> Parser<T> {
  return Parser {s in
    if let (a, s2) = p.parse(s) {
      return (a, s2)
    }
    else {
      return q.parse(s)
    }
  }
}

// prounounced "apply". The '<*>' function takes a Parser (T -> U) and some
// Parser T, and returns the Parser U from the application of T to T -> U.
func <*> <T, U>(_ p: Parser<(T) -> U>, _ q: Parser<T>) -> Parser<U> {
  return p >>- { f in f <^> q }
}

func <* <T, U>(_ p: Parser<T>, _ q: Parser<U>) -> Parser<T> {
  return const <^> p <*> q
}

func *> <T, U>(_ p: Parser<T>, _ q: Parser<U>) -> Parser<U> {
  return const(id) <^> p <*> q
}




