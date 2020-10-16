#* This file is part of the MOOSE framework
#* https://www.mooseframework.org
#*
#* All rights reserved, see COPYRIGHT for full restrictions
#* https://github.com/idaholab/moose/blob/master/COPYRIGHT
#*
#* Licensed under LGPL 2.1, please see LICENSE for details
#* https://www.gnu.org/licenses/lgpl-2.1.html
import sys
import collections
import logging
import json

import moosetree
import mooseutils
from .nodes import SyntaxNode, MooseObjectNode, ActionNode, MooseObjectActionNode

def get_moose_syntax_tree(exe, remove=None, hide=None, alias=None, unregister=None,
                          allow_test_objects=False, app_types=None):
    """
    Creates a tree structure representing the MooseApp syntax for the given executable using --json.

    Inputs:
      ext[str|dict]: The executable to run or the parsed JSON tree structure
      remove[list|dict]: Syntax to mark as removed. The input data structure can be a single list or
                         a dict of lists.
      hide[list|dict]: Syntax to mark as hidden. The input data structure can be a single list or
                       a dict of lists.
      alias[dict]: A dict of alias information; the key is the actual syntax and the value is the
                   alias to be applied (e.g., {'/Kernels/Diffusion':'/Physics/Diffusion'}).
      unregister[dict]: A dict of classes with duplicate registration information; the key is the
                        "moose_base" name and the value is the syntax from which the object should be
                        removed (e.g., {"Postprocessor":"UserObject/*"}).
    """
    # Create the JSON tree, unless it is provided directly
    if isinstance(exe, dict):
        tree = exe
    else:
        raw = mooseutils.runExe(exe, ['--json', '--allow-test-objects'])
        raw = raw.split('**START JSON DATA**\n')[1]
        raw = raw.split('**END JSON DATA**')[0]
        tree = mooseutils.json_parse(raw)

    # Build the complete syntax tree
    root = SyntaxNode(None, '')
    for key, value in tree['blocks'].items():
        node = SyntaxNode(root, key)
        __syntax_tree_helper(node, value)

    # Build hide/remove sets
    hidden = __build_set_from_yaml(hide)
    removed = __build_set_from_yaml(remove)

    # Initialize dict if not provided
    alias = alias or dict()
    unregister = unregister or dict()
    for key in list(unregister.keys()):
        if isinstance(unregister[key], dict):
            unregister.update(unregister.pop(key))

    # Apply remove/hide/alias/unregister restrictions
    for node in moosetree.iterate(root):

        # Hidden
        if node.fullpath() in hidden:
            node.hidden = True

        # Removed
        if (node.fullpath() in removed) or ((node.parent is not None) and node.parent.removed):
            node.removed = True

        # Remove 'Test' objects if not allowed
        if (not allow_test_objects) and node.groups() and all(grp.endswith('TestApp') for grp in node.groups()):
            node.removed =  True

        # Remove unregistered items
        for base, parent_syntax in unregister.items():
            if (node.name == base) and (node.get('action_path') == parent_syntax):
                node.removed = True

            if (node.get('moose_base') == base) and (node.get('parent_syntax') == parent_syntax):
                node.removed = True

        # Apply alias
        for name, alt in alias.items():
            if node.fullpath() == name:
                node.alias = str(alt)

        # Limit to given app types
        if ((node.parent is not None) and (not node.parent.in_app)) or \
           ((app_types is not None) and not any([app_type in node.groups() for app_type in app_types])):
            node.in_app = False

    return root

def __build_set_from_yaml(item):
    """Helper for converting list/dict structure from YAML file to single set."""
    out = set()
    if isinstance(item, dict):
        for value in item.values():
            out.update(value)
    elif isinstance(item, (list, set)):
        out.update(item)
    return out

def __syntax_tree_helper(parent, item):
    """Helper to build the proper node from the supplied JSON item."""

    if item is None:
        return

    if 'actions' in item:
        for key, action in item['actions'].items():
            action['tasks'] = set(action['tasks'])
            if ('parameters' in action) and action['parameters'] and \
            ('isObjectAction' in action['parameters']):
                MooseObjectActionNode(parent, key, **action)
            else:
                ActionNode(parent, key, **action)

    if 'star' in item:
        __syntax_tree_helper(parent, item['star'])

    if ('types' in item) and item['types']:
        for key, obj in item['types'].items():
            MooseObjectNode(parent, key, **obj)

    if ('subblocks' in item) and item['subblocks']:
        for k, v in item['subblocks'].items():
            node = SyntaxNode(parent, k)
            __syntax_tree_helper(node, v)

    if ('subblock_types' in item) and item['subblock_types']:
        for k, v in item['subblock_types'].items():
            MooseObjectNode(parent, k, **v)
