import SwiftSyntax

let p = try! SyntaxParser.parse(source: "import Foo")
dump(p)
