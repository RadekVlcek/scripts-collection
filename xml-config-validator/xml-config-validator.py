# DISCLAIMER: This script is not functional anymore and serves only for pleasure of your eyes

# Description: validate important XML configuartion file against XML schema

import xmlschema

my_schema = xmlschema.XMLSchema('.\xml-schema.xsd')
result = my_schema.is_valid('.\config-file.xml')

if result != "True":
    print("WARNING: Errors were found in your config file!")
    print("Validate the document on https://www.xmlvalidation.com/ and fix the errors immediately!")
    
else:
    print("Your config file is valid, no errors found.")