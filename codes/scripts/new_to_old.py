import os
import torch
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('input')
parser.add_argument('output')
args = parser.parse_args()

new_net = torch.load(args.input)
old_net = {}

print('###################################\n')
tbd = []
for k, v in new_net.items():
    tbd.append(k)

old_net['model.0.weight'] = new_net['conv_first.weight']
old_net['model.0.bias'] = new_net['conv_first.bias']

for k in tbd.copy():
    if 'RDB' in k:
        ori_k = k.replace('RRDB_trunk.', 'model.1.sub.')
        if '.weight' in k:
            ori_k = ori_k.replace('.weight', '.0.weight')
        elif '.bias' in k:
            ori_k = ori_k.replace('.bias', '.0.bias')
        old_net[ori_k] = new_net[k]
        tbd.remove(k)

old_net['model.1.sub.23.weight'] = new_net['trunk_conv.weight']
old_net['model.1.sub.23.bias'] = new_net['trunk_conv.bias']
old_net['model.3.weight'] = new_net['upconv1.weight']
old_net['model.3.bias'] = new_net['upconv1.bias']
old_net['model.6.weight'] = new_net['upconv2.weight']
old_net['model.6.bias'] = new_net['upconv2.bias']
old_net['model.8.weight'] = new_net['HRconv.weight']
old_net['model.8.bias'] = new_net['HRconv.bias']
old_net['model.10.weight'] = new_net['conv_last.weight']
old_net['model.10.bias'] = new_net['conv_last.bias']

print('Saving to ', args.output)
torch.save(old_net, args.output)
