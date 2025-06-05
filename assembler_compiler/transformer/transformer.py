from enum import Enum
from typing import List

from ply.lex import LexToken

from transformer.parser import get_lexer_instance

REGS_AMMOUNT = 16  # Ammount of CPU registers (starting from r0)
ADDRESS_STEP = 1


class Section(Enum):
    data = "data"
    text = "text"


def parse_tokens(tokens: List[LexToken], expected_len: int, expected_types: List[str]):
    if len(tokens) != expected_len:
        raise TypeError("len {reg_tokens} != {expected_len}")
    for i, token in enumerate(tokens):
        if token.type != expected_types[i]:
            raise TypeError(f"not a {expected_types[i]}: {token}")
    return [token.value for token in tokens]


def int_to_hex_str(num, leading_zeros_count):
    if isinstance(num, str):
        num = int(num)
    return format(num, f"0{leading_zeros_count}X")


def transform(filename: str):
    instruction_file = open(filename, "r")

    lexer = get_lexer_instance()
    errors = []

    to_write_program: str = ""
    to_write_data = ""
    address_count_program: int = 0
    address_count_data: int = 0

    data = {}

    current_section: Section

    labels = {}

    def add_to_write_program(line: str):
        nonlocal to_write_program, address_count_program
        to_write_program += line + "\n"
        address_count_program += ADDRESS_STEP

    def add_to_write_data(line: str):
        nonlocal to_write_data, address_count_data
        to_write_data += line + "\n"
        address_count_data += ADDRESS_STEP

    for i_line, line in enumerate(instruction_file):
        tokens = lexer.test(line)
        if len(tokens) == 0:
            continue

        main_token = tokens[0]
        tokens.pop(0)

        try:
            match main_token.type:
                case "SECTION":
                    current_section = Section[main_token.value]

                case "LABEL":
                    if current_section == Section.data:
                        params = parse_tokens(
                            tokens,
                            1,
                            ["NUMBER"],
                        )
                        data[main_token.value] = address_count_data
                        to_write = f"{int_to_hex_str(params[0], 4)}"
                        add_to_write_data(to_write)

                    elif current_section == Section.text:
                        labels[main_token.value] = address_count_program

                case "0" | "1" | "2" | "3":
                    if current_section != Section.text:
                        raise TypeError(
                            f"Prohibited syntax in .data: {main_token.value}. Use .text"
                        )
                    regs = parse_tokens(
                        tokens,
                        3,
                        ["REG"] * 3,
                    )
                    for i, r in enumerate(regs):
                        if r > REGS_AMMOUNT - 1 or r < 0:
                            raise TypeError(
                                f"Register doesn't exist: {main_token.value}"
                            )
                        regs[i] = int_to_hex_str(r, 1)

                    to_write = f"{main_token.type}{regs[0]}{regs[1]}{regs[2]}"
                    add_to_write_program(to_write)
                case "4" | "5":
                    var = parse_tokens(
                        tokens,
                        1,
                        ["VAR"],
                    )
                    var_addr = data.get(var[0])

                    if var_addr is None:
                        raise TypeError(f"Variable doesn't exist: {var[0]}")

                    to_write = f"{main_token.type}{int_to_hex_str(var_addr, 3)}"
                    add_to_write_program(to_write)
                case "6" | "7":
                    label = parse_tokens(
                        tokens,
                        1,
                        ["VAR"],
                    )

                    label_addr = labels.get(label[0])

                    if label_addr is None:
                        raise TypeError(f"Label doesn't exist: {label[0]}")

                    to_write = f"{main_token.type}{int_to_hex_str(label_addr, 3)}"
                    add_to_write_program(to_write)
                case _:
                    raise TypeError(f"Unknown syntax: {main_token.value}")
        except TypeError as e:
            errors.append(
                f'in line {i_line + 1} ("{line.strip().replace("\n", "")}"): \n{str(e)}'
            )

    if len(errors) != 0:
        print("\n[Errors]\n")
        for e in errors:
            print(e, "\n")
    else:
        print(to_write_program)
        print("\n")
        print(to_write_data)

        write_filename = filename.split(".")[0]
        data_file = open(f"{write_filename}_data.mem", "w")
        program_file = open(f"{write_filename}_program.mem", "w")
        data_file.write(to_write_data)
        program_file.write(to_write_program)
        data_file.close()
        program_file.close()

    instruction_file.close()
