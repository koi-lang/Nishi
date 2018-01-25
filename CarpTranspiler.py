#!/usr/bin/env python
# -*- coding: utf-8 -*-
""""""

import antlr4

from CarpLexer import CarpLexer
from CarpListener import CarpListener
from CarpParser import CarpParser


class CarpInterpreter(CarpListener):
    def __init__(self):
        pass


if __name__ == "__main__":
    lexer = CarpLexer(antlr4.FileStream("example.carp"))
    stream = antlr4.CommonTokenStream(lexer)
    parser = CarpParser(stream)
    tree = parser.program()

    interpret = CarpInterpreter()
    walker = antlr4.ParseTreeWalker()
    walker.walk(interpret, tree)

