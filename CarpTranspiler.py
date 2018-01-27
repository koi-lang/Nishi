#!/usr/bin/env python
# -*- coding: utf-8 -*-
""""""

import antlr4

from CarpLexer import CarpLexer
from CarpListener import CarpListener
from CarpParser import CarpParser

import io
from ast import literal_eval


class CarpTranspiler(CarpListener):
    def __init__(self, output: io.FileIO):
        self.output = output

        self.context = None
        self.access = None
        self.indent = " "

        self.variables = {}

        self.python_to_csharp = {str: "string",
                                 int: "int",
                                 float: "float",
                                 list: "List<>",
                                 bool: "bool",
                                 None: "null"}

        self.carp_to_csharp = {"String": "string",
                               "Integer": "int",
                               "Float": "float",
                               "List": "List<>",
                               "Boolean": "bool",
                               "None": "null"}

        self.output.write("using System.Collections.Generic;\n\n")

    # Normal Classes

    def enterNormalClass(self, ctx:CarpParser.NormalClassContext):
        self.output.write(f"class {str(ctx.ID())} %s" % "{\n")

        self.context = str(ctx.ID())
        self.indent *= 4

    def exitNormalClass(self, ctx:CarpParser.NormalClassContext):
        self.output.write("}\n\n")

        self.context = None
        self.indent = " "

    # Normal Functions

    def enterNormalFunction(self, ctx:CarpParser.NormalFunctionContext):
        if self.context is not None:
            self.output.write(f"\n{self.indent}public {'void ' if str(ctx.ID()) != self.context else ''}{str(ctx.ID())}() %s" % "{\n")

    def exitNormalFunction(self, ctx:CarpParser.NormalFunctionContext):
        self.output.write(f"{self.indent}%s\n" % "}")

    # Override Functions

    def enterOverrideFunction(self, ctx:CarpParser.OverrideFunctionContext):
        if self.context is not None:
            self.output.write(f"\n{self.indent}public override {str(ctx.ID())}() %s" % "{\n")

    def exitOverrideFunction(self, ctx:CarpParser.OverrideFunctionContext):
        self.output.write(f"{self.indent}%s\n" % "}")

    # Function Setters

    def enterFunctionSetter(self, ctx:CarpParser.FunctionSetterContext):
        if self.context is not None:
            self.output.write(f"\n{self.indent}public {str(ctx.ID())}() %s" % "{\n")

    def exitFunctionSetter(self, ctx:CarpParser.FunctionSetterContext):
        self.output.write(f"{self.indent}%s\n" % "}")

    # Override Function Setters

    def enterOverrideFunctionSetter(self, ctx:CarpParser.OverrideFunctionSetterContext):
        if self.context is not None:
            self.output.write(f"\n{self.indent}public override {str(ctx.ID())}() %s" % "{\n")

    def exitOverrideFunctionSetter(self, ctx:CarpParser.OverrideFunctionSetterContext):
        self.output.write(f"{self.indent}%s\n" % "}")

    # Private Block

    def enterPrivate_block(self, ctx:CarpParser.Private_blockContext):
        self.access = "private"

    def exitPrivate_block(self, ctx:CarpParser.Private_blockContext):
        self.access = None

    # Public Block

    def enterPublic_block(self, ctx:CarpParser.Public_blockContext):
        self.access = "public"

    def exitPublic_block(self, ctx:CarpParser.Public_blockContext):
        self.access = None

    # Assignment

    def enterAssignment(self, ctx:CarpParser.AssignmentContext):
        type_ = ctx.type_().getText() if ctx.type_() is not None else None
        value = ctx.value().getText() if ctx.value() is not None else None

        string = []

        if self.access is not None:
            string.append(self.access)

        if value and self.access is not None:
            string.append(self.python_to_csharp[type(literal_eval(value))])

        elif value and self.access is None:
            string.append("var")

        if type_:
            string.append(self.carp_to_csharp[type_])

        string.append(f"{ctx.ID()}")

        if value:
            string.append(f"= {value}")

        self.output.write(f"{self.indent}{' '.join(string)};\n")


if __name__ == "__main__":
    file = "simple_class"

    lexerer = CarpLexer(antlr4.FileStream(f"{file}.carp"))
    stream = antlr4.CommonTokenStream(lexerer)
    parser = CarpParser(stream)
    tree = parser.program()

    with open(f"{file}.cs", "w") as out:
        interpreter = CarpTranspiler(out)
        walker = antlr4.ParseTreeWalker()
        walker.walk(interpreter, tree)
