from enum import Enum
from pathlib import Path
from typing import List

from ply.lex import LexToken

from transformer.parser import get_lexer_instance

REGS_AMOUNT = 16
ADDRESS_STEP = 1
OUTPUT_FILENAME_PROGRAM = "program.mem"
OUTPUT_FILENAME_DATA = "data.mem"


class Section(Enum):
    data = "data"
    text = "text"


def parse_tokens(
    tokens: List[LexToken], expected_len: int, expected_types: List[str]
) -> List[str]:
    if len(tokens) != expected_len:
        raise TypeError(f"Expected {expected_len} tokens, got {len(tokens)}")
    for i, token in enumerate(tokens):
        if token.type != expected_types[i]:
            raise TypeError(f"Expected {expected_types[i]}, got {token.type}")
    return [token.value for token in tokens]


def int_to_hex_str(num, leading_zeros_count) -> str:
    if isinstance(num, str):
        num = int(num)
    return format(num, f"0{leading_zeros_count}X")


def transform(input_path: str, output_dir: str) -> None:
    """
    Transforms assembly script from the given path and outputs to given directory

    :param str input_path: Path of the input assembly file
    :param str output_dir: Path of the directory to output to
    :return: None; Generates files to given path or prints errors
    :rtype: None
    """

    path = Path(input_path)
    lines = path.read_text().splitlines()
    lexer = get_lexer_instance()

    to_write_program = ""
    to_write_data = ""
    address_count_program = 0
    address_count_data = 0
    data = {}
    labels = {}
    errors = []

    def add_to_write_program(line: str):
        nonlocal to_write_program, address_count_program
        to_write_program += line + "\n"
        address_count_program += ADDRESS_STEP

    def add_to_write_data(line: str):
        nonlocal to_write_data, address_count_data
        to_write_data += line + "\n"
        address_count_data += ADDRESS_STEP

    # ----------- FIRST PASS: Resolve label addresses and .data section  ----------
    current_section = None
    for i_line, line in enumerate(lines):
        tokens = lexer.test(line)
        if not tokens:
            continue

        main_token = tokens.pop(0)

        if main_token.type == "SECTION":
            current_section = Section[main_token.value]

        elif main_token.type == "LABEL":
            if current_section == Section.data:
                try:
                    params = parse_tokens(tokens, 1, ["NUMBER"])
                    data[main_token.value] = address_count_data
                    add_to_write_data(int_to_hex_str(params[0], 4))
                except TypeError as e:
                    errors.append(f"Line {i_line + 1} [{line.strip()}]: {e}")
            elif current_section == Section.text:
                labels[main_token.value] = address_count_program

        elif main_token.type in {"0", "1", "2", "3", "4", "5", "6", "7"}:
            if current_section == Section.text:
                address_count_program += ADDRESS_STEP

    # ----------- SECOND PASS: Emit instructions using resolved labels -----
    address_count_program = 0  # Reset before second pass
    current_section = None

    for i_line, line in enumerate(lines):
        tokens = lexer.test(line)
        if not tokens:
            continue

        main_token = tokens.pop(0)

        try:
            match main_token.type:
                case "SECTION":
                    current_section = Section[main_token.value]

                case "LABEL":
                    continue  # already handled in pass 1

                case "0" | "1" | "2" | "3":
                    if current_section != Section.text:
                        raise TypeError("Instruction found outside .text section")

                    regs = parse_tokens(tokens, 3, ["REG"] * 3)
                    for i, r in enumerate(regs):
                        if r >= REGS_AMOUNT or r < 0:
                            raise TypeError(f"Invalid register: %r{r}")
                        regs[i] = int_to_hex_str(r, 1)

                    line_hex = f"{main_token.type}{regs[0]}{regs[1]}{regs[2]}"
                    add_to_write_program(line_hex)

                case "4" | "5":  # lw/sw
                    var = parse_tokens(tokens, 1, ["VAR"])[0]
                    if var not in data:
                        raise TypeError(f"Undefined variable: {var}")

                    addr = int_to_hex_str(data[var], 3)
                    add_to_write_program(f"{main_token.type}{addr}")

                case "6" | "7":  # beq/jmp
                    label = parse_tokens(tokens, 1, ["VAR"])[0]
                    if label not in labels:
                        raise TypeError(f"Undefined label: {label}")

                    addr = int_to_hex_str(labels[label], 3)
                    add_to_write_program(f"{main_token.type}{addr}")

                case _:
                    raise TypeError(f"Unknown token type: {main_token.type}")

        except TypeError as e:
            errors.append(f"Line {i_line + 1} [{line.strip()}]: {e}")

    # ----------- OUTPUT STATUS OR ERRORS ---------------
    if errors:
        print("\n[Errors]\n")
        for e in errors:
            print(e)
    else:
        print("[Success]")
        print(f"Files program.mem and data.mem generated in {output_dir}/")

        Path(output_dir).mkdir(parents=True, exist_ok=True)
        (Path(output_dir) / OUTPUT_FILENAME_PROGRAM).write_text(to_write_program)
        (Path(output_dir) / OUTPUT_FILENAME_DATA).write_text(to_write_data)
