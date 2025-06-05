from typing import List

import ply.lex as lex

# Reserved instruction and their codes
reserved = {
    "add": "0",
    "sub": "1",
    "and": "2",
    "or": "3",
    "lw": "4",
    "sw": "5",
    "beq": "6",
    "jmp": "7",
}


class AssemblyLexer(object):
    # List of token names.
    tokens = (
        "LABEL",
        "VAR",
        "SECTION",
        "NUMBER",
        "REG",
    ) + tuple(reserved.values())

    # Regular expression rules for tokens

    def t_LABEL(self, t):
        r"[a-zA-Z]+:"
        t.value = t.value.replace(":", "")
        return t

    def t_VAR(self, t):
        r"[a-zA-Z]+"
        t.type = reserved.get(t.value.lower(), "VAR")
        return t

    def t_SECTION(self, t):
        r"\.[a-zA-Z]+"
        t.value = t.value.replace(".", "")
        return t

    def t_NUMBER(self, t):
        r"\d+"
        t.value = int(t.value)
        return t

    def t_REG(self, t):
        r"%r\d+"
        t.value = int(t.value.replace("%r", ""))
        return t

    # Define a rule so we can track line numbers (not used)
    # def t_newline(self, t):
    #     r"\n+"
    #     t.lexer.lineno += len(t.value)

    # A string containing ignored characters (spaces and tabs)
    t_ignore = " \t"

    # Error handling rule
    def t_error(self, t):
        print("Illegal character '%s'" % t.value[0])
        t.lexer.skip(1)

    # Build the lexer
    def build(self, **kwargs):
        self.lexer = lex.lex(module=self, **kwargs)

    # Test input
    def test(self, data) -> List[lex.LexToken]:
        self.lexer.input(data)
        tokens = []
        while True:
            tok = self.lexer.token()
            if not tok:
                break
            tokens.append(tok)
        return tokens


LEXER = AssemblyLexer()
LEXER.build()


# Singleton instance
def get_lexer_instance() -> AssemblyLexer:
    return LEXER
