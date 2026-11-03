# C64 BASIC V2 build pipeline. Python 3.9+, no third-party dependencies.
import argparse
import shutil
import os
import re
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_VICE_BIN = Path(r'D:\GTK3VICE-3.10-win64\bin')
LINE = re.compile(r'^\s*(\d+)\s*(.*)$')
UNSUPPORTED = re.compile(r'(?<![A-Za-z0-9_])(CLS|CLEAR)(?![A-Za-z0-9_])', re.I)

class BuildError(Exception):
    pass

def diagnostic(path, lineno, message, severity='error'):
    print(f'{path}({lineno}): {severity}: {message}', flush=True)

def normalize_listing(source, path):
    """Make ASCII letters PETCAT-safe, without changing the original .bas.

    PETCAT -w2 expects lower-case ASCII to represent C64 uppercase letters.
    PETCAT is not a conventional case-insensitive BASIC compiler. Therefore
    we normalize keywords AND normal text in quotes for upper/graphics mode.
    C64 case semantics are different from a modern Unicode editor.
    """
    if source.startswith('\ufeff'):
        source = source[1:]
    seen = set()
    converted = []
    errors = 0
    for n, original in enumerate(source.splitlines(), 1):
        if not original.strip():
            continue
        match = LINE.match(original)
        if not match:
            diagnostic(path, n, 'Expected a BASIC line number at the beginning.')
            errors += 1
            continue
        num = int(match.group(1))
        stmt = match.group(2)
        if num < 0 or num > 63999:
            diagnostic(path, n, 'Line number must be between 0 and 63999.')
            errors += 1
        if num in seen:
            diagnostic(path, n, f'Duplicate BASIC line number {num}.')
            errors += 1
        seen.add(num)
        if stmt.count('"') % 2:
            diagnostic(path, n, 'Unterminated quoted string.')
            errors += 1
        if any(ord(c) > 127 for c in stmt):
            diagnostic(path, n, 'Only ASCII is accepted (Greek, Unicode and smart quotes need PETSCII mapping).')
            errors += 1
        # Warn only for plainly unsupported commands outside strings and REM/DATA.
        outside = stmt.split('"')[0].split('REM')[0].split('rem')[0]
        for match2 in UNSUPPORTED.finditer(outside):
            diagnostic(path, n, f'Not a BASIC V2 command: {match2.group(1)}.', 'warning')
        # ASCII upper->lower also inside quoted text: this is required to
        # display conventional uppercase on the default C64 character set.
        converted.append(f'{num} {stmt.lower()}')
    if errors:
        raise BuildError(f'{errors} source validation error(s)')
    if not converted:
        raise BuildError('Empty BASIC listing')
    return '\n'.join(converted) + '\n'

def vice_bin():
    return Path(os.environ.get('VICE_BIN', str(DEFAULT_VICE_BIN)))

def build(source_path, launch=False):
    source_path = Path(source_path).resolve()
    if not source_path.is_file():
        raise BuildError(f'Listing not found: {source_path}')
    if source_path.suffix.lower() == '.asm':
        return build_asm(source_path, launch)
    petcat = vice_bin() / 'petcat.exe'
    emulator = vice_bin() / 'x64sc.exe'
    if not petcat.is_file():
        raise BuildError(f'petcat.exe not found: {petcat}; edit VICE_BIN in run-c64.bat')
    if launch and not emulator.is_file():
        raise BuildError(f'x64sc.exe not found: {emulator}')
    try:
        text = source_path.read_text(encoding='utf-8-sig')
    except UnicodeError:
        raise BuildError('Could not read listing as UTF-8')
    normalized = normalize_listing(text, source_path)
    temp_dir = ROOT / '.build'
    temp_dir.mkdir(exist_ok=True)
    tmp = temp_dir / (source_path.stem + '.petcat.txt')
    out = source_path.with_suffix('.prg')
    tmp.write_text(normalized, encoding='ascii')
    if out.exists():
        out.unlink()  # Never run a stale PRG after a failed build.
    print(f'C64: building {source_path}', flush=True)
    result = subprocess.run([str(petcat), '-w2', '-o', str(out), '--', str(tmp)],
                            capture_output=True, text=True, errors='replace')
    if result.returncode or not out.is_file():
        raise BuildError(f'PETCAT failed ({result.returncode}): {(result.stderr or result.stdout).strip()}')
    raw = out.read_bytes()
    if len(raw) < 9 or raw[:2] != b'\x01\x08':
        out.unlink(missing_ok=True)
        raise BuildError('PRG validation failed: missing $0801 BASIC load address')
    # First statement must be tokenized when it starts with a known keyword.
    first_statement = normalized.splitlines()[0].split(' ', 1)[1].lstrip()
    first_token = {'print': 0x99, 'for': 0x81, 'rem': 0x8f, 'poke': 0x97,
                   'sys': 0x9e, 'goto': 0x89, 'input': 0x85, 'if': 0x8b}
    keyword = re.match(r'^[a-z]+', first_statement)
    if keyword and keyword.group() in first_token and raw[6] != first_token[keyword.group()]:
        out.unlink(missing_ok=True)
        raise BuildError(f'PRG token validation failed: {keyword.group()} was not tokenized')
    print(f'C64: OK -> {out} ({len(raw)} bytes)', flush=True)
    if launch:
        # Do not terminate existing emulator windows: other C64 sessions may be running.
        subprocess.Popen([str(emulator), '-autostart', str(out)], cwd=str(vice_bin()))
        print('C64: VICE launched. Close prior VICE windows manually if necessary.', flush=True)
    return out

def find_64tass():
    """64tass from TASS (a full path), next to this script, or on the PATH."""
    candidates = [os.environ.get('TASS', ''), str(Path(__file__).with_name('64tass.exe')),
                  shutil.which('64tass') or '']
    for c in candidates:
        if c and Path(c).is_file():
            return c
    raise BuildError('64tass not found: put 64tass.exe in lab\\tools or set TASS')

TASS_MESSAGE = re.compile(r'^(.+?):(\d+):\d+: (error|warning): (.+)$')

def tass_diagnostics(output):
    """Turn 64tass messages (file:line:col: error: text) into the lab's format."""
    found = []
    for line in output.splitlines():
        m = TASS_MESSAGE.match(line.strip())
        if m:
            found.append((m.group(1), int(m.group(2)), m.group(3), m.group(4)))
    return found

def build_asm(source_path, launch=False):
    tass = find_64tass()
    emulator = vice_bin() / 'x64sc.exe'
    if launch and not emulator.is_file():
        raise BuildError(f'x64sc.exe not found: {emulator}')
    out = source_path.with_suffix('.prg')
    if out.exists():
        out.unlink()  # Never run a stale PRG after a failed build.
    print(f'C64: assembling {source_path}', flush=True)
    result = subprocess.run([tass, '-C', '-a', '-i', '-Wall', str(source_path), '-o', str(out)],
                            capture_output=True, text=True, errors='replace',
                            cwd=str(source_path.parent))
    messages = tass_diagnostics(result.stdout + '\n' + result.stderr)
    for file, line, severity, text in messages:
        diagnostic(Path(source_path.parent, file).resolve(), line, text, severity)
    if result.returncode or not out.is_file():
        raise BuildError(f'64tass failed ({result.returncode})')
    raw = out.read_bytes()
    print(f'C64: OK -> {out} ({len(raw)} bytes, load address ${raw[0] | raw[1] << 8:04x})', flush=True)
    if launch:
        subprocess.Popen([str(emulator), '-autostart', str(out)], cwd=str(vice_bin()))
        print('C64: VICE launched. Close prior VICE windows manually if necessary.', flush=True)
    return out

def sources(directory):
    return {p: p.stat().st_mtime_ns for pattern in ('*.bas', '*.asm')
            for p in directory.rglob(pattern) if p.is_file()}

def watch(directory, launch):
    directory = Path(directory).resolve()
    print(f'C64 WATCH: observing saved .bas and .asm files in {directory}', flush=True)
    print('C64 WATCH: idle', flush=True)
    # Snapshot initial state; only future saves trigger builds.
    known = sources(directory)
    while True:
        time.sleep(0.7)
        current = sources(directory)
        for p, mtime in sorted(current.items()):
            if known.get(p) != mtime:
                print(f'C64 WATCH: processing {p.name}', flush=True)
                try:
                    build(p, launch=launch)
                except (BuildError, OSError) as e:
                    diagnostic(p, 1, str(e))
                print('C64 WATCH: idle', flush=True)
        known = current

def main():
    parser = argparse.ArgumentParser(description='C64 build (BASIC V2 with petcat, 6502 assembly with 64tass) + VICE launcher')
    parser.add_argument('listing', nargs='?')
    parser.add_argument('--run', action='store_true')
    parser.add_argument('--watch', metavar='DIR')
    args = parser.parse_args()
    try:
        if args.watch:
            watch(args.watch, args.run)
        elif args.listing:
            build(args.listing, args.run)
        else:
            parser.error('Pass a .bas or .asm file, or --watch DIRECTORY')
    except (BuildError, OSError) as e:
        diagnostic(args.listing or args.watch or ROOT, 1, str(e))
        return 1
    except KeyboardInterrupt:
        return 0
    return 0

if __name__ == '__main__':
    sys.exit(main())
