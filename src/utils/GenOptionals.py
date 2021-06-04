#!/usr/bin/python3

import sys
import itertools

if sys.argv == 1:
    print(f'Usage: {sys.argv[0]} [string ...]')
    exit(1)

tokens = sys.argv[1:]
opts_i = []

for i in range(len(tokens)):
    if 'Opt' in tokens[i]:
        opts_i.append(i)
        tokens[i] = tokens[i][:-3]

masks = list(itertools.product([True,False], repeat=len(opts_i)))
for i in range(len(masks)):
    masks[i] = [*masks[i]]

for m in masks:
    print('			    |', end=' ')
    for i, to in enumerate(tokens):
        if i in opts_i:
            if m.pop():
                print(to, end=' ')
        else:
            print(to, end=' ')
    print()
