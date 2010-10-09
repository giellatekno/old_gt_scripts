#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
sys.path.append(os.getenv('GTHOME') + '/gt/script')

import netfile_getter
import unittest

class TestArticleSaver(unittest.TestCase):

    def test_fillbuffer(self):
        c = netfile_getter.ArticleSaver()

        # Check if a non-empty string is returned
        f = c.fillbuffer('http://divvun.no')
        self.assertNotEqual(c.filebuffer, '')

        # Check if None is returned for a non-existent site
        f = c.fillbuffer('http://quatch.no/fake.html')
        self.assertEqual(f, False)

        # Check if None is returned for a non-existant file
        f = c.fillbuffer('http://quatch.no/fake.html')
        self.assertEqual(f, False)

if __name__ == '__main__':
    unittest.main()