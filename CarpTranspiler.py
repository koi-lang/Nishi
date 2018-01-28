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
import sys
import argparse


class CarpTranspiler(CarpListener):
    def __init__(self, output: io.FileIO, pretty: bool=True):
        self.output = output

        self.pretty_print = pretty

        self.context = None
        self.context_type = ""
        self.access = None
        self.package = False

        self.variable_contexts = {"classes": {},
                                  "functions": {}}

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
                               "Void": "void",
                               "None": "null"}

        self.insert_text("using System;{}using System.Collections.Generic".format("\n" if self.pretty_print else ""), 1, True)

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
        self.context = str(ctx.ID())
        self.context_type = "classes"
        self.variable_contexts["classes"][str(ctx.ID())] = []

        self.insert_text(f"class {str(ctx.ID())} %s" % "{", 1)

        self.do_indent()

    def exitNormalClass(self, ctx:CarpParser.NormalClassContext):
        self.context = None
        self.do_dedent()

        self.insert_text("}", 1)

    # Normal Functions

    def enterNormalFunction(self, ctx:CarpParser.NormalFunctionContext):
        if self.context is not None:
            self.context = str(ctx.ID())
            self.context_type = "functions"
            self.variable_contexts["functions"][str(ctx.ID())] = []

            self.insert_text(f"public {str(ctx.ID())}() %s" % "{", 1)

        self.do_indent()

    def exitNormalFunction(self, ctx:CarpParser.NormalFunctionContext):
        # self.context = None
        self.do_dedent()

        self.insert_text("}", 1)

    # Override Functions

    def enterOverrideFunction(self, ctx:CarpParser.OverrideFunctionContext):
        if self.context is not None:
            self.context = str(ctx.ID())
            self.context_type = "functions"
            self.variable_contexts["functions"][str(ctx.ID())] = []

            self.insert_text(f"public override {str(ctx.ID())}() %s" % "{", 1)

        self.do_indent()

    def exitOverrideFunction(self, ctx:CarpParser.OverrideFunctionContext):
        # self.context = None
        self.do_dedent()

        self.insert_text("}", 1)

    # Function Setters

    def enterFunctionSetter(self, ctx:CarpParser.FunctionSetterContext):
        if self.context is not None:
            self.context = str(ctx.ID())
            self.context_type = "functions"
            self.variable_contexts["functions"][str(ctx.ID())] = []

            self.insert_text(f"public {self.carp_to_csharp[str(ctx.type_().getText())]} {str(ctx.ID())}() %s" % "{", 1)

        self.do_indent()

    def exitFunctionSetter(self, ctx:CarpParser.FunctionSetterContext):
        # self.context = None
        self.do_dedent()

        self.insert_text("}", 1)

    # Override Function Setters

    def enterOverrideFunctionSetter(self, ctx:CarpParser.OverrideFunctionSetterContext):
        if self.context is not None:
            self.context = str(ctx.ID())
            self.context_type = "functions"
            self.variable_contexts["functions"][str(ctx.ID())] = []

            self.insert_text(f"public override {str(ctx.ID())}() %s" % "{", 1)

        self.do_indent()

    def exitOverrideFunctionSetter(self, ctx:CarpParser.OverrideFunctionSetterContext):
        # self.context = None
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

        if str(ctx.ID()) not in self.variable_contexts[self.context_type][self.context]:
            if value and self.access is not None:
                string.append(self.python_to_csharp[type(literal_eval(value))])

            elif value and self.access is None:
                string.append("var")

        if type_:
            string.append(self.carp_to_csharp[type_])

        string.append(f"{ctx.ID()}")

        if value:
            string.append(f"= {value}")

        self.variable_contexts[self.context_type][self.context].append(str(ctx.ID()))

        self.insert_text(f"{' '.join(string)}", 1, True)

    # Print

    def enterPrint_(self, ctx:CarpParser.Print_Context):
        values = [i.getText() for i in ctx.value()]
        values.append('"\\n"')

        prints = []

        for item in values:
            prints.append(f"Console.Write({item})")

        self.insert_text("; ".join(prints), 1, True)

    # Other Methods

    def do_indent(self):
        self.indent += " " * 4

    def do_dedent(self):
        self.indent = self.indent[:-4]

    def insert_text(self, text: str, newlines: int=0, line_end: bool=False):
        if self.pretty_print:
            self.output.write(f"{self.indent}{text}{';' if line_end else ''}{os.linesep * newlines}")

        else:
            self.output.write(f"{text}{';' if line_end else ''}")

        # print(self.context, self.variable_contexts)


if __name__ == "__main__":
    parse_args = argparse.ArgumentParser()
    parse_args.add_argument("-f", "--file", type=str, help="the Carp file")
    parse_args.add_argument("-p", "--pretty", action="store_true", help="pretty print the C# file")
    args = parse_args.parse_args()

    file = args.file
    pretty = args.pretty

    # file = "simple_class.carp"
    # pretty = True

    if file is None:
        sys.exit()

    lexerer = CarpLexer(antlr4.FileStream(file))
    stream = antlr4.CommonTokenStream(lexerer)
    parser = CarpParser(stream)
    tree = parser.program()

    with open(f"{str(file).split('.')[0]}.cs", "w") as out:
        interpreter = CarpTranspiler(out, pretty)
        walker = antlr4.ParseTreeWalker()
        walker.walk(interpreter, tree)
