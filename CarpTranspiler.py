#!/usr/bin/env python
# -*- coding: utf-8 -*-
""""""

import antlr4

from CarpLexer import CarpLexer
from CarpListener import CarpListener
from CarpParser import CarpParser

import io


class CarpTranspiler(CarpListener):
    def __init__(self, output: io.FileIO):
        self.output = output

        self.context = None

    def enterNormalClass(self, ctx:CarpParser.NormalClassContext):
        self.output.write(f"class {str(ctx.ID())}%s" % "{")

    def exitNormalClass(self, ctx:CarpParser.NormalClassContext):
        self.output.write("}")


if __name__ == "__main__":
    lexerer = CarpLexer(antlr4.FileStream("example.carp"))
    stream = antlr4.CommonTokenStream(lexerer)
    parser = CarpParser(stream)
    tree = parser.program()

    with open("example.cs", "w") as out:
        interpreter = CarpTranspiler(out)
        walker = antlr4.ParseTreeWalker()
        walker.walk(interpreter, tree)
