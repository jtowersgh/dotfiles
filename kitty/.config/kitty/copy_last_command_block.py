#!/usr/bin/env python3

import re
import sys

from kitty.clipboard import set_clipboard_string
from kittens.tui.handler import result_handler


OSC_133_A = re.compile(r"\x1b\]133;A(?:\x07|\x1b\\)")
OSC_133_C = re.compile(r"\x1b\]133;C(?:;[^\x07\x1b]*)?(?:\x07|\x1b\\)")

ANSI_ESCAPE = re.compile(
    r"""
    \x1b
    (?:
        \[[0-?]*[ -/]*[@-~]
      | \][^\x07]*(?:\x07|\x1b\\)
      | [()][0-2A-Z]
      | [=>]
      | [78]
      | [#][0-9]
    )
    """,
    re.VERBOSE,
)


def clean_output(data: str) -> str:
    data = ANSI_ESCAPE.sub("", data)
    data = data.replace("\r", "")
    return data


def extract_last_command_block(data: str) -> str:
    prompts = list(OSC_133_A.finditer(data))

    if len(prompts) < 2:
        return ""

    # Everything between the previous shell prompt marker and
    # the current shell prompt marker.
    start = prompts[-2].end()
    end = prompts[-1].start()
    block = data[start:end]

    commands = list(OSC_133_C.finditer(block))

    if not commands:
        return ""

    outputs = []

    # Each OSC 133;C marker precedes the output belonging to
    # that command.
    for index, command_marker in enumerate(commands):
        output_start = command_marker.end()

        if index + 1 < len(commands):
            output_end = commands[index + 1].start()
        else:
            output_end = len(block)

        outputs.append(clean_output(block[output_start:output_end]))

    return "".join(outputs)


def main(args):
    # Kitty supplies ansi-history on stdin. Consume the entire stream.
    return sys.stdin.read()


@result_handler(type_of_input="ansi-history")
def handle_result(
    args,
    stdin_data: str,
    target_window_id: int,
    boss,
):
    result = extract_last_command_block(stdin_data)

    if result:
        set_clipboard_string(result)
