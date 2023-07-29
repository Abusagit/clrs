import json
import argparse
import sys
import logging
import glob
import pandas as pd
from typing import List, Dict, Any, Union
from pathlib import Path


def get_parser() -> argparse.ArgumentParser:
    
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input_dir", type=str, help="Path to root directory of a run")
    parser.add_argument("-p", "--pattern", type=str, 
                        default=None, 
                        help="You can provide pattern of a directory where to find dumps. Will be used instead of 'input_dir'. If provided, 'outdir' must be provided as well")
    parser.add_argument("-f", "--files", default=None, help="Provided list of files instead of directory", nargs="*")
    parser.add_argument("-o", "--outdir", type=str, default='', help="Output file path. Will be overwritten!")
    
    return parser

def get_logger() -> logging.Logger:
    root = logging.getLogger()

    root.setLevel(logging.DEBUG)
        
    stringfmt = "[%(asctime)s] [%(threadName)s] [%(name)s] [%(levelname)s] %(message)s"
    datefmt = "%Y-%m-%d %H:%M:%S"
    formatter = logging.Formatter(fmt=stringfmt, datefmt=datefmt)

    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(formatter)
    root.addHandler(console_handler)

    return root


def parse_root_directory_get_dumps(root_dir: str, maybe_pattern: Union[str, None], maybe_files: Union[None, List[str]]) -> List[Dict[str, Any]]:
    
    pattern: str = maybe_pattern if maybe_pattern else f"{root_dir}/*/val_test_dump.json"
    
    dump_files: List[str] = glob.glob(pattern, recursive=True) if not maybe_files else maybe_files
    
    print(dump_files)
    overall_dump: List[Dict[str, Any]] = []
    
    for dump_file in dump_files:
        with open(dump_file) as handler:
            
            dump: List[Dict[str, Any]] = json.load(handler)
            
            overall_dump.extend(dump)
    
    return overall_dump
    
    
def main():
    
    parser = get_parser()
    
    root = get_logger()
    
    args = parser.parse_args()
    root.info(f"Parsed args are: {args}")
    
    dump: List[Dict[str, Any]] = parse_root_directory_get_dumps(root_dir=args.input_dir, maybe_pattern=args.pattern, maybe_files=args.files)
    root.info(f"Got list of all dumps from {args.input_dir}")
    
    dataframe = pd.DataFrame.from_dict(dump)
    root.info("Created dataframe from list of dumps")
    
    
    if args.outdir:
        outdir = Path(args.outdir)
    elif args.input_dir:
        outdir = Path(args.input_dir)
    else:
        outdir = Path.cwd()
        
    outfile = outdir / "dumps_df.csv"
    
    dataframe.to_csv(
        path_or_buf=outfile,
    )
    
    root.info(f"Dataframe saved to {outfile}")
    root.info("Done")


if __name__ == '__main__':
    main()