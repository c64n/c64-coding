import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('c64', Path(__file__).resolve().parents[1] / 'tools' / 'c64.py')
c64 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c64)

class TestPreprocessor(unittest.TestCase):
    def test_uppercase_token_and_text(self):
        result = c64.normalize_listing('10 PRINT CHR$(147)\n20 PRINT "HELLO FROM VS CODE!"\n', 'test.bas')
        self.assertEqual(result, '10 print chr$(147)\n20 print "hello from vs code!"\n')
    def test_reject_duplicated_number(self):
        with self.assertRaises(c64.BuildError):
            c64.normalize_listing('10 PRINT 1\n10 PRINT 2\n', 'test.bas')
    def test_reject_non_ascii(self):
        with self.assertRaises(c64.BuildError):
            c64.normalize_listing('10 PRINT "ΓΕΙΑ"\n', 'test.bas')
    def test_reject_quotes(self):
        with self.assertRaises(c64.BuildError):
            c64.normalize_listing('10 PRINT "HI\n', 'test.bas')

class TestAssembler(unittest.TestCase):
    def test_64tass_messages(self):
        out = ('dodge.asm:57:14: error: not defined symbol \'scrol\'\n'
               ' jsr scrol\n'
               'dodge.asm:3:1: warning: unused symbol\n')
        self.assertEqual(c64.tass_diagnostics(out),
                         [('dodge.asm', 57, 'error', "not defined symbol 'scrol'"),
                          ('dodge.asm', 3, 'warning', 'unused symbol')])

if __name__ == '__main__':
    unittest.main()
