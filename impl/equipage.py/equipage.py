#!/usr/bin/env python

"""equipage.py - Python implementation of Equipage."""


MARKER = ()


def pop(stack):
    if not stack:
        raise ValueError
    return stack[0], stack[1:]


def push(stack, elem):
    return [elem] + stack


def pick(stack, index):
    if index > 0:
        return stack[index-1]
    elif index < 0:
        return stack[index]
    else:
        return 0


def dump_stack(stack):
    def z(e):
        if isinstance(e, list):
            return '<fn>'
        else:
            return str(e)
    return '[{}]'.format(','.join([z(e) for e in stack]))


def apply_(func, stack, trace=None):
    if trace is not None:
        trace.append((func, stack))
        #print((func, stack))
    if func == 'Apply':
        e, r1 = pop(stack)
        return apply_(e, r1, trace=trace)
    elif func == 'Compose':
        a, r1 = pop(stack)
        b, r2 = pop(r1)
        r3 = push(r2, ['Concat', a, b])
        return r3
    elif func == 'Pop':
        e, rest = pop(stack)
        return rest
    elif func == 'Swap':
        a, r1 = pop(stack)
        b, r2 = pop(r1)
        r3 = push(r2, a)
        r4 = push(r3, b)
        return r4
    elif func == 'Add':
        a, r1 = pop(stack)
        b, r2 = pop(r1)
        r3 = push(r2, a + b)
        return r3
    elif func == 'Sub':
        a, r1 = pop(stack)
        b, r2 = pop(r1)
        r3 = push(r2, b - a)
        return r3
    elif func == 'Sign':
        a, r1 = pop(stack)
        if a > 0:
            a = 1
        elif a < 0:
            a = -1
        else:
            a = 0
        r2 = push(r1, a)
        return r2
    elif func == 'Pick':
        a, r1 = pop(stack)
        e = pick(r1, a)
        return push(r1, e)
    elif func == 'One':
        return push(stack, 1)
    elif func == 'Mark':                  # EquipageQ only
        return push(stack, MARKER)
    elif func == 'Define':                # EquipageQ only
        func = 'Nop'
        v, stack = pop(stack)
        while v != MARKER:
            func = ['Concat', func, v]
            v, stack = pop(stack)
        return push(stack, func)
    elif func == 'Nop':
        return stack
    elif isinstance(func, list):
        fhead = func[0]
        if fhead == 'Push':
            return push(stack, func[1])
        elif fhead == 'Concat':
            r1 = apply_(func[2], stack, trace=trace)
            r2 = apply_(func[1], r1, trace=trace)
            return r2
        else:
            raise NotImplementedError(func)
    else:
        raise NotImplementedError(func)


def parse(string, support_equipageq=False):
    semantics = {
        '!': 'Apply',
        ';': ['Push', 'Apply'],
        '.': ['Push', 'Compose'],
        '$': ['Push', 'Pop'],
        '\\':['Push', 'Swap'],
        '+': ['Push', 'Add'],
        '-': ['Push', 'Sub'],
        '%': ['Push', 'Sign'],
        '~': ['Push', 'Pick'],
        '1': ['Push', 'One'],
        ' ': 'Nop',
        '\t': 'Nop',
        '\n': 'Nop',
        '\r': 'Nop',
    }

    if support_equipageq:
        semantics.update({
            '(': ['Push', 'Mark'],
            ')': ['Push', 'Define'],
        })

    func = 'Nop'
    for char in string:
        func = ['Concat', semantics[char], func]

    return func


if __name__ == '__main__':
    import sys
    from argparse import ArgumentParser
    argparser = ArgumentParser(__doc__.strip())
    argparser.add_argument(
        'filename', metavar='FILENAME', type=str,
        help="The Equipage source file to run."
    )
    argparser.add_argument(
        "-Q", "--support-equipageq",
        action="store_true",
        help="Support EquipageQ instructions `(` and `)`."
    )
    argparser.add_argument(
        "--trace",
        action="store_true",
        help="Display execution trace."
    )
    options = argparser.parse_args(sys.argv[1:])

    with open(options.filename, 'r') as f:
        program_text = f.read()
    program = parse(program_text, support_equipageq=options.support_equipageq)

    trace = [] if options.trace else None
    result = apply_(program, [], trace=trace)
    if trace is not None:
        for (func, stack) in trace:
            print(func, stack)

    print(dump_stack(result))
