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
        self.indent = " "

    def enterNormalClass(self, ctx:CarpParser.NormalClassContext):
        self.output.write(f"class {str(ctx.ID())} %s" % "{\n")

        self.context = str(ctx.ID())
        self.indent *= 4

    def exitNormalClass(self, ctx:CarpParser.NormalClassContext):
        self.output.write("}\n\n")

        self.context = None
        self.indent = " "

    def enterNormalFunction(self, ctx:CarpParser.NormalFunctionContext):
        if self.context is not None:
            self.output.write(f"{self.indent}public {'void ' if str(ctx.ID()) != self.context else ''}{str(ctx.ID())}() %s" % "{\n")

    def exitNormalFunction(self, ctx:CarpParser.NormalFunctionContext):
        self.output.write(f"{self.indent}%s\n" % "}\n")

    def enterOverrideFunction(self, ctx:CarpParser.OverrideFunctionContext):
        if self.context is not None:
            self.output.write(f"{self.indent}public override {str(ctx.ID())}() %s" % "{\n")

    def exitOverrideFunction(self, ctx:CarpParser.OverrideFunctionContext):
        self.output.write(f"{self.indent}%s\n" % "}\n")

    def enterFunctionSetter(self, ctx:CarpParser.FunctionSetterContext):
        if self.context is not None:
            self.output.write(f"{self.indent}public {str(ctx.ID())}() %s" % "{\n")

    def exitFunctionSetter(self, ctx:CarpParser.FunctionSetterContext):
        self.output.write(f"{self.indent}%s\n" % "}\n")

    def enterOverrideFunctionSetter(self, ctx:CarpParser.OverrideFunctionSetterContext):
        if self.context is not None:
            self.output.write(f"{self.indent}public override {str(ctx.ID())}() %s" % "{\n")

    def exitOverrideFunctionSetter(self, ctx:CarpParser.OverrideFunctionSetterContext):
        self.output.write(f"{self.indent}%s\n" % "}\n")


if __name__ == "__main__":
    lexerer = CarpLexer(antlr4.FileStream("example.carp"))
    stream = antlr4.CommonTokenStream(lexerer)
    parser = CarpParser(stream)
    tree = parser.program()

    with open("example.cs", "w") as out:
        interpreter = CarpTranspiler(out)
        walker = antlr4.ParseTreeWalker()
        walker.walk(interpreter, tree)
