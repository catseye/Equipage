#include <stdlib.h>
#include <stdio.h>


/**** Data Structures ****/

enum fntype {
    APPLY,
    COMPOSE,
    POP,
    SWAP,
    ADD,
    SUB,
    SIGN,
    PICK,
    ONE,
    NOP,

    CONCAT,
    PUSH
};

struct function {
    enum fntype      fntype;
    struct function *lhs;
    struct function *rhs;
};

struct elem {
    long int         num;
    struct function *fn;
};

struct stack {
    struct elem     *elems;
    int              top;
};


struct stack *new_stack(int size) {
    struct stack *s;

    s = malloc(sizeof(struct stack));
    s->elems = malloc(size * sizeof(struct elem));

    return s;
};


/**** Stack Utilities ****/

void copy_elem(struct elem *src, struct elem *dest) {
    dest->num = src->num;
    dest->fn  = src->fn;
}


void pop(struct stack *stack, struct elem *out) {
    copy_elem(&stack->elems[stack->top], out);
    stack->top--;
}


void push(struct stack *stack, struct elem *in) {
    stack->top++;
    copy_elem(in, &stack->elems[stack->top]);
}


void pick(struct stack *stack, int index, struct elem *out) {
    if (index > 0) {
        copy_elem(&stack->elems[stack->top - index], out);
    } else if (index < 0) {
        copy_elem(&stack->elems[(-1) - index], out);
    } else {
        struct elem c;
        c.num = 0;
        c.fn = NULL;
        copy_elem(&c, out);
    }
}


/**** Function Utilities ****/

/*
 * This function takes ownership of the lhs and rhs passed to it.
 */
struct function *make_function(enum fntype fntype, struct function *lhs, struct function *rhs) {
    struct function *fn;

    fn = malloc(sizeof(struct function));
    fn->fntype = fntype;
    fn->lhs = lhs;
    fn->rhs = rhs;

    return fn;
}


struct function *make_push(enum fntype fntype) {
    return make_function(PUSH, make_function(fntype, NULL, NULL), NULL);
}


struct function *copy_function(struct function *src) {
    return make_function(src->fntype, src->lhs, src->rhs);
}


void dump_function(struct function *fn) {
    switch (fn->fntype) {
        case APPLY:
            printf("apply");
            break;
        case COMPOSE:
            printf("compose");
            break;
        case POP:
            printf("pop");
            break;
        case SWAP:
            printf("swap");
            break;
        case ADD:
            printf("add");
            break;
        case SUB:
            printf("sub");
            break;
        case SIGN:
            printf("sign");
            break;
        case PICK:
            printf("pick");
            break;
        case ONE:
            printf("one");
            break;
        case NOP:
            printf("nop");
            break;

        case PUSH:
            printf("(push ");
            dump_function(fn->lhs);
            printf(")");
            break;
        case CONCAT:
            printf("(concat ");
            dump_function(fn->lhs);
            printf(" ");
            dump_function(fn->rhs);
            printf(")");
            break;
    }
}


/**** Evaluation ****/

void apply_(struct function *fn, struct stack *stack) {
    struct elem a, b, c;

    switch (fn->fntype) {
        case APPLY:
            pop(stack, &a);
            apply_(a.fn, stack);
            break;
        case COMPOSE:
            pop(stack, &a);
            pop(stack, &b);
            c.num = 0;
            /* Even though a and b are local variables, the functions they point to, aren't.  So this is OK. */
            /* (I think.) */
            c.fn = make_function(CONCAT, a.fn, b.fn);
            push(stack, &c);
            break;
        case POP:
            pop(stack, &a);
            break;
        case SWAP:
            pop(stack, &a);
            pop(stack, &b);
            push(stack, &a);
            push(stack, &b);
            break;
        case ADD:
            pop(stack, &a);
            pop(stack, &b);
            c.num = a.num + b.num;
            c.fn = NULL;
            push(stack, &c);
            break;
        case SUB:
            pop(stack, &a);
            pop(stack, &b);
            c.num = b.num - a.num;
            c.fn = NULL;
            push(stack, &c);
            break;
        case SIGN:
            pop(stack, &a);
            if (a.num > 0) {
                a.num = 1;
            } else if (a.num < 0) {
                a.num = -1;
            } else {
                a.num = 0;
            }
            push(stack, &a);
            break;
        case PICK:
            pop(stack, &a);
            pick(stack, a.num, &c);
            push(stack, &c);
            break;
        case ONE:
            a.num = 1;
            a.fn = NULL;
            push(stack, &a);
            break;
        case NOP:
            break;

        case PUSH:
            a.num = 0;
            a.fn = fn->lhs;
            push(stack, &a);
            break;
        case CONCAT:
            apply_(fn->rhs, stack);
            apply_(fn->lhs, stack);
            break;
    }
}        


struct function *semantics(char c) {
    switch (c) {
        case '!':
            return make_function(APPLY, NULL, NULL);
        case ';':
            return make_push(APPLY);
        case '.':
            return make_push(COMPOSE);
        case '$':
            return make_push(POP);
        case '\\':
            return make_push(SWAP);
        case '+':
            return make_push(ADD);
        case '-':
            return make_push(SUB);
        case '%':
            return make_push(SIGN);
        case '~':
            return make_push(PICK);
        case '1':
            return make_push(ONE);
        default:
            return make_function(NOP, NULL, NULL);
    }
}


struct function *parse_stream(FILE *stream) {
    char c;
    struct function *fn;

    fn = make_function(NOP, NULL, NULL);

    c = fgetc(stream);
    while (!feof(stream)) {
        fn = make_function(CONCAT, semantics(c), fn);
        c = fgetc(stream);
    }

    return fn;
}


int main(int argc, char **argv) {
    FILE *f;
    struct function *program;

    f = fopen(argv[1], "r");
    if (!f) {
        fprintf(stderr, "Couldn't open '%s' for reading\n", argv[1]);
        exit(1);
    }

    program = parse_stream(f);
    fclose(f);

    dump_function(program);

    return 0;
}
