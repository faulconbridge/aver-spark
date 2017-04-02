#!/usr/bin/python

import avro.schema
from avro.datafile import DataFileReader, DataFileWriter
from avro.io import DatumReader, DatumWriter
import argparse

# Basic arg parsing
parser = argparse.ArgumentParser(description="CSV-to-Avro Converter")
parser.add_argument("-f", "--filename", help="CSV input file");
parser.add_argument("-o", "--output", help="Avro output destination");
parser.add_argument("-s", "--schemafile", help="Path to Avro schema file");

args = parser.parse_args();

# Read in schema file
schema = avro.schema.Parse(open(args.schemafile, "rb").read())

# Read input CSV
# Currently this'll just read everything into memory
# rather than batch things or stream them. Mostly
# because it's a small dataset and there's no 

# ...

# Write our Avro file to disk
writer = DataFileWriter(open(args.output, "wb"), DatumWriter(), schema)
# writer.append({"name": "Ben", "favorite_number": 7, "favorite_color": "red"})
writer.close()