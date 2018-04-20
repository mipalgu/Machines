import Functional

/**
 * The Parser structure.
 *
 * A Parser is just a wrapper around a parse function: `String -> (T, String)?`
 */
struct Parser<T> {
  let parse: (String) -> (T, String)?
}

enum Error {
  case message(String)
}

enum Either<T, U> {
  case left(T)
  case right(U)
}

/**
 * The `id`entity function.
 *
 * - parameter t: Some T.
 * - returns: The same T.
 */
func id<T>(_ t: T) -> T {
  return t
}

/**
 *  The `const` function.
 *
 *  `const` takes an input and returns a function expecting an input, that 
 *  returns this input.
 *
 *  - paramter t: Some T.
 *  - returns: A function U -> T where T is t.
 */
func const<T, U>(_ t: T) -> (U) -> T {
  return { _ in t }
}

/**
 *  The `cons` function.
 *
 *  `cons` is a functional method for prepending an item to the front of a
 *  collection: `a -> t a -> t a`.
 *
 * - parameter x: some (T : RangeReplaceableCollection).Iterator.Element.
 * - returns: A function (T) -> T
 *            
 */
func cons<T : RangeReplaceableCollection>(_ x: T.Iterator.Element) -> (T) 
  -> T {
  return {xs in
    var xs = xs
    xs.insert(x, at: xs.startIndex)
    return xs
  }
}

/**
 *  The `uncons` function
 * 
 *  `uncons` takes a collection and returns a tuple with the (head, tail).
 *
 *  - parameter xs: some Collection T.
 *  - returns: an optional (T.Iterator.Element, T.SubSequence)
 *
 */
func uncons<T: Collection>(_ xs: T) -> (T.Iterator.Element, T.SubSequence)? {
  if let head = xs.first {
    return (head, xs.suffix(from: xs.index(after: xs.startIndex)))
  } 
  else {
    return nil
  }
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

func between<T, U, V>(_ start: Parser<T>, _ end: Parser<U>, _ p: Parser<V>)
  -> Parser<V> {
  return (start *> p <* end)
}

func run<T>(_ p: Parser<T>, _ s: String) -> Either<Error,T> {
  if let (result, s) = p.parse(s) {
    let r : Either<Error, T> = .right(result)
    let l : Either<Error, T> = .left(Error.message(s))
    return s.isEmpty ? r : l
  }
  else {
    return Either.left(Error.message("Some unknown error occured!"))
  }
}




