import sys

from transformer import transform

if __name__ == "__main__":
    args = sys.argv
    if len(args) > 1:
        transform(args[1])
    else:
        print("No filename provided. \nUsage: python main.py FILENAME.EXT")
