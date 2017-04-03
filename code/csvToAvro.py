#!/usr/bin/python

################################################################################
#
# Imports
#
################################################################################

import argparse
import csv
import sys
import avro.schemafrom collections import namedtuple
from avro.datafile import DataFileReader, DataFileWriter
from avro.io import DatumReader, DatumWriter

################################################################################
#
# CLI arg parsing
#
################################################################################

parser = argparse.ArgumentParser(description="CSV-to-Avro Converter")
parser.add_argument("-f", "--filename", help="Path to CSV input file");
parser.add_argument("-s", "--schemafile", help="Path to Avro schema file");
parser.add_argument("-o", "--output", help="Path to Avro output destination");

args = parser.parse_args();

fields = ("playerID", "yearID", "stint", "teamID", "lgID",
    "W", "L", "G", "GS", "CG", "SHO", "SV", "IPouts", "H",
    "ER", "HR", "BB", "SO", "BAOpp", "ERA", "IBB", "WP",
    "HBP", "BK", "BFP", "GF", "R", "SH", "SF", "GIDP")

################################################################################
#
# User-Defined Functions
#
################################################################################

# Going this (named tuple) route since data type
# conversion seemed marginally less hairy here
# than using a dict. That said, there's probably
# A Better Way (tm) to do this such that field
# names and data types aren't hardcoded, but it
# works well enough in the context of this specific
# example.
class DataReader(namedtuple('Player', fields)):

    @classmethod
    def parse(dataType, row):
        row = list(row)
        row[1]  = int(row[1]) if row[1] else None
        row[2]  = int(row[2]) if row[2] else None
        row[5]  = int(row[5]) if row[5] else None
        row[6]  = int(row[6]) if row[6] else None
        row[7]  = int(row[7]) if row[7] else None
        row[8]  = int(row[8]) if row[8] else None
        row[9]  = int(row[9]) if row[9] else None
        row[10] = int(row[10]) if row[10] else None
        row[11] = int(row[11]) if row[11] else None
        row[12] = int(row[12]) if row[12] else None
        row[13] = int(row[13]) if row[13] else None
        row[14] = int(row[14]) if row[14] else None
        row[15] = int(row[15]) if row[15] else None
        row[16] = int(row[16]) if row[16] else None
        row[17] = int(row[17]) if row[17] else None
        row[18] = float(row[18]) if row[18] else None
        row[19] = float(row[19]) if row[19] else None
        row[20] = int(row[20]) if row[20] else None
        row[21] = int(row[21]) if row[21] else None
        row[22] = int(row[22]) if row[22] else None
        row[23] = int(row[23]) if row[23] else None
        row[24] = int(row[24]) if row[24] else None
        row[25] = int(row[25]) if row[25] else None
        row[26] = int(row[26]) if row[26] else None
        row[27] = int(row[27]) if row[27] else None
        row[28] = int(row[28]) if row[28] else None
        row[29] = int(row[29]) if row[29] else None

        return dataType(*row)

def read_data(path):
    with open(path, 'rU') as data:
        data.readline()
        reader = csv.reader(data)
        for row in map(DataReader.parse, reader):
            yield row

def parse_schema(path):
    with open(path, 'r') as schema:
        return avro.schema.Parse(schema.read())

# There's no compelling reason to convert our
# CSV to an Avro binary other than I don't know
# as much about the file format as I'd like and
# was curious. Since these data are coming to us
# already in a columnar format and we're writing
# SQL-like queries against them, it would probably
# make more sense to convert the data to Parquet
# if we're optimizing for performance.
def convert_to_avro(records, schema, output):
    schema = parse_schema(schema)
    with open(output, 'wb') as out:
        writer = DataFileWriter(out, DatumWriter(), schema)
        for record in records:
            record = dict((field, getattr(record, field)) for field in record._fields)
            writer.append(record)
        writer.close()

################################################################################
#
# Dataset ingestion
#
################################################################################

data = read_data(args.filename)

################################################################################
#
# CSV-To-Avro Conversion
#
################################################################################

convert_to_avro(data, args.schemafile, args.output)
