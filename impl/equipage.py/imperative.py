#!/usr/bin/env python

"""equipage.py - Python implementation of Equipage."""


MARKER = ()


def pop(stack):
    return stack.pop()


def push(stack, elem):
    stack.append(elem)


def pick(stack, index):
    if index > 0:
        return stack[0-index]
    elif index < 0:
        return stack[(-1)-index]
    else:
        return 0


def dump_stack(stack):
    def z(e):
        if isinstance(e, list):
            return '<fn>'
        else:
            return str(e)
    return '[{}]'.format(','.join(reversed([z(e) for e in stack])))


def apply_(func, stack, trace=None):
    if trace is not None:
        trace.append((func, stack))
        #print((func, stack))
    if func == 'Apply':
        e = pop(stack)
        apply_(e, stack, trace=trace)
    elif func == 'Compose':
        a = pop(stack)
        b = pop(stack)
        push(stack, ['Concat', a, b])
    elif func == 'Pop':
        e = pop(stack)
    elif func == 'Swap':
        a = pop(stack)
        b = pop(stack)
        push(stack, a)
        push(stack, b)
    elif func == 'Add':
        a = pop(stack)
        b = pop(stack)
        push(stack, a + b)
    elif func == 'Sub':
        a = pop(stack)
        b = pop(stack)
        push(stack, b - a)
    elif func == 'Sign':
        a = pop(stack)
        if a > 0:
            a = 1
        elif a < 0:
            a = -1
        else:
            a = 0
        push(stack, a)
    elif func == 'Pick':
        a = pop(stack)
        e = pick(stack, a)
        push(stack, e)
    elif func == 'One':
        push(stack, 1)
    elif func == 'Nop':
        return
    elif isinstance(func, list):
        fhead = func[0]
        if fhead == 'Push':
            push(stack, func[1])
        elif fhead == 'Concat':
            apply_(func[2], stack, trace=trace)
            apply_(func[1], stack, trace=trace)
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
    stack = []
    apply_(program, stack, trace=trace)
    if trace is not None:
        for (func, s) in trace:
            print(func, s)

    print(dump_stack(stack))
