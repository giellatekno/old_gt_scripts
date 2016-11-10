#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''Print se and fi entries from the daily termwiki dump to stdout

The se and fi output are separated by a tab.

If there are several expressions in each language, they are separated by
a comma.
'''
from __future__ import print_function
import collections
import lxml.etree as etree
import os
import sys

sys.path.append(os.path.join(os.getenv('GTHOME'), 'tools/TermWikiImporter'))

from termwikiimporter import bot
from termwikiimporter import importer



DUMP = os.path.join(os.getenv('GTHOME'), 'words/terms/termwiki/dump.xml')

tree = etree.parse(DUMP)

for text in tree.getroot().xpath(
        './/m:text',
        namespaces={'m': 'http://www.mediawiki.org/xml/export-0.10/'}):
    if text.text is not None:
        sanctioned = {}
        concept = importer.Concept()
        lines = collections.deque(text.text.split(u'\n'))

        l = lines.popleft()
        if l.startswith(u'{{Concept'):
            try:
                (concept_info, sanctioned) = bot.parse_concept(lines)
                for key, info in concept_info.iteritems():
                    concept.add_concept_info(key, info)
                while len(lines) > 0:
                    l = lines.popleft()
                    if (l.startswith(u'{{Related expression') or
                            l.startswith(u'{{Related_expression')):
                        try:
                            (expression_info, pos) = bot.parse_related_expression(lines, sanctioned)
                        except bot.BotException:
                            break
                        concept.add_expression(expression_info)
                        concept.expression_infos.pos = pos
                    elif l.startswith(u'{{Related concept'):
                        concept.add_related_concept(bot.parse_related_concept(lines))
                    else:
                        raise BotException('unhandled', l.strip())
            except importer.ExpressionException:
                pass
            except KeyError:
                pass
            except ValueError:
                pass
            else:
                se = concept.expression_infos.get_expressions_set(u'se')
                fi = concept.expression_infos.get_expressions_set(u'fi')
                if se or fi:
                    print('\t'.join(
                        [','.join(se), ','.join(fi)]))

