import argparse
from pathlib import Path

from transformer import transform

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Transform assembler file into CPU intructions and output to desired path."
    )
    parser.add_argument("filename", help="Input filename (e.g., filename.s)")
    parser.add_argument(
        "-o", "--output", required=True, help="Path to output directory"
    )

    args = parser.parse_args()

    # Convert to absolute Path objects based on current working dir
    input_path = Path(args.filename).resolve()
    output_path = Path(args.output).resolve()

    transform(input_path, output_path)
