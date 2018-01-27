#!/usr/bin/env python
# -*- coding: utf-8 -*-
""""""

import antlr4

from CarpLexer import CarpLexer
from CarpListener import CarpListener
from CarpParser import CarpParser

import io
from ast import literal_eval
import os


class CarpTranspiler(CarpListener):
    def __init__(self, output: io.FileIO):
        self.output = output

        self.context = None
        self.access = None
        self.package = False

        self.indent = ""

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

        self.insert_text("using System;\nusing System.Collections.Generic", 1, True)

    # Package

    def enterPackage(self, ctx:CarpParser.PackageContext):
        self.insert_text(f"namespace {ctx.ID()[0]} %s" % "{", 1)
        self.do_indent()

        self.package = True

    def exitProgram(self, ctx:CarpParser.ProgramContext):
        if self.package:
            self.context = None
            self.do_dedent()

            self.insert_text("}", 1)

    # Normal Classes

    def enterNormalClass(self, ctx:CarpParser.NormalClassContext):
        self.insert_text(f"class {str(ctx.ID())} %s" % "{", 1)

        self.context = str(ctx.ID())
        self.do_indent()

    def exitNormalClass(self, ctx:CarpParser.NormalClassContext):
        self.context = None
        self.do_dedent()

        self.insert_text("}", 1)

    # Normal Functions

    def enterNormalFunction(self, ctx:CarpParser.NormalFunctionContext):
        if self.context is not None:
            self.insert_text(f"public {'void ' if str(ctx.ID()) != self.context else ''}{str(ctx.ID())}() %s" % "{", 1)

        self.do_indent()

    def exitNormalFunction(self, ctx:CarpParser.NormalFunctionContext):
        self.do_dedent()

        self.insert_text("}", 1)

    # Override Functions

    def enterOverrideFunction(self, ctx:CarpParser.OverrideFunctionContext):
        if self.context is not None:
            self.insert_text(f"public override {str(ctx.ID())}() %s" % "{", 1)

        self.do_indent()

    def exitOverrideFunction(self, ctx:CarpParser.OverrideFunctionContext):
        self.do_dedent()

        self.insert_text("}", 1)

    # Function Setters

    def enterFunctionSetter(self, ctx:CarpParser.FunctionSetterContext):
        if self.context is not None:
            self.insert_text(f"public {str(ctx.ID())}() %s" % "{", 1)

        self.do_indent()

    def exitFunctionSetter(self, ctx:CarpParser.FunctionSetterContext):
        self.do_dedent()

        self.insert_text("}", 1)

    # Override Function Setters

    def enterOverrideFunctionSetter(self, ctx:CarpParser.OverrideFunctionSetterContext):
        if self.context is not None:
            self.insert_text(f"public override {str(ctx.ID())}() %s" % "{", 1)

        self.do_indent()

    def exitOverrideFunctionSetter(self, ctx:CarpParser.OverrideFunctionSetterContext):
        self.do_dedent()

        self.insert_text("}", 1)

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

        self.insert_text(f"{' '.join(string)}", 1, True)

    # Print

    def enterPrint_(self, ctx:CarpParser.Print_Context):
        values = [i.getText() for i in ctx.value()]

        for item in values:
            self.insert_text(f"Console.Write({item})", 1, True)

    # Other Methods

    def do_indent(self):
        self.indent += " " * 4

    def do_dedent(self):
        self.indent = self.indent[:-4]

    def insert_text(self, text: str, newlines: int=0, line_end: bool=False):
        self.output.write(f"{self.indent}{text}{';' if line_end else ''}{os.linesep * newlines}")


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
