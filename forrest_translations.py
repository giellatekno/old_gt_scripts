#!/usr/bin/env python
# -*- coding: utf-8 -*-


import os
import lxml.etree as etree
import argparse


def update_translation_catalogue(catalogue_file, labels):
    translations = etree.parse(catalogue_file)
    catalogue = translations.getroot()

    for label in labels:
        if catalogue.find('./message[@key="' + label + '"]') is None:
            message = etree.Element('message')
            message.set('key', label)
            message.text = label
            catalogue.append(message)

    with open(catalogue_file, 'w') as xml:
        poff = etree.tostring(translations,
                              encoding='UTF-8',
                              pretty_print=True,
                              xml_declaration=True)

        xml.write(
            poff.replace('\n<mess',
                         '\n  <mess').replace(
                             '><m', '>\n  <m').replace(
                                 '></ca', '>\n</ca'))


def read_labels(xmlfile):
    labels = []
    parser = etree.XMLParser(remove_blank_text=True)
    tree = etree.parse(xmlfile, parser)

    for element in tree.getroot().xpath('.//*[@label]'):
        labels.append(element.get('label'))

    return labels


def parse_options():
    parser = argparse.ArgumentParser(
        description='Update the menu and tab translation catalogs')
    parser.add_argument('forrest_site',
                        help='The forrest site')
    parser.add_argument('langs', help="list of languages",
                        nargs='+')

    return parser.parse_args()


def main():
    args = parse_options()

    huff = {'site.xml': 'menu_',
            'tabs.xml': 'tabs_'}

    for key, value in huff.items():
        labels = read_labels(
            os.path.join(
                args.forrest_site,
                'src/documentation/content/xdocs',
                key))

        for lang in args.langs:
            catalogue_file = os.path.join(
                args.forrest_site,
                'src/documentation/translations',
                value + lang + '.xml')
            update_translation_catalogue(catalogue_file, labels)

if __name__ == "__main__":
    main()
