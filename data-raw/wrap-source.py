"""One-off, syntax-preserving line wrapping before styler and R parsing."""
from pathlib import Path
import re
import textwrap

for root in (Path("R"), Path("tests/testthat")):
    for path in root.glob("*.R"):
        lines = path.read_text(encoding="utf-8").splitlines()
        output = []
        for line in lines:
            if len(line) <= 78:
                output.append(line)
                continue
            if line.startswith("#'") and not any(s in line for s in ("<-", "sl_", "package =")):
                output.extend(textwrap.wrap(line[3:], width=73,
                    initial_indent="#' ", subsequent_indent="#' ",
                    break_long_words=False, break_on_hyphens=False))
                continue
            remainder = line
            for _ in range(10):
                if len(remainder) <= 78:
                    break
                quote = None
                escaped = False
                positions = []
                for index, char in enumerate(remainder):
                    if quote:
                        if escaped:
                            escaped = False
                        elif char == "\\":
                            escaped = True
                        elif char == quote:
                            quote = None
                    elif char in ('"', "'", '`'):
                        quote = char
                    elif char == '#':
                        break
                    elif char in (',', '('):
                        positions.append(index + 1)
                usable = [pos for pos in positions if 10 <= pos <= 68]
                if not usable:
                    break
                pos = max(usable)
                prefix = re.match(r"\s*", remainder).group()
                if remainder.lstrip().startswith("#'"):
                    prefix += "#' "
                output.append(remainder[:pos].rstrip())
                remainder = prefix + "  " + remainder[pos:].lstrip()
            output.append(remainder)
        path.write_text("\n".join(output) + "\n", encoding="utf-8")
