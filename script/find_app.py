#!/usr/bin/env python3
import argparse

import re
import sys
import copy

parser = argparse.ArgumentParser()
parser.add_argument('--input', type=str, default='hello_world',
                help="name of app")
args = parser.parse_args()


import os

root_dir ='./app'

dir_to_find = args.input
for root, dirs, files in os.walk(root_dir):
    if dir_to_find in dirs:
        print(os.path.join(root, dir_to_find))
        exit()



