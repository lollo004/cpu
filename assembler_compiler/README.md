# Assembler Compiler
Custom compiler for Verilog CPU, compiling from custom assembly code into CPU hex intructions. 

## Usage

1. Install Python dependences via Poetry (https://python-poetry.org):
    `poetry install`
2. Run main.py, providing filename of the assembler script:
    `poetry run python main.py FILENAME.EXT -o path/to/output`

    **OR**
    
    Call `transform()` function manually:
    ```
    from transformer import transform
    from pathlib import Path
    
    input_path = Path('input_file.ext').resolve()
    output_path = Path('path/to/output').resolve()
    
    transform(input_path, output_path)
    ```
