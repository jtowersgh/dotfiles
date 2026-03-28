#!/usr/bin/env python3

import sys
import re

YEAR = "2026"

ACCOUNT_MAP = {
    "FREE CHECKING FIXED": "Assets:DCU:Checking",
    "FREE CHECKING UTILITY": "Assets:DCU:Utility",
}

RULES = {
    "VERIZON": "Expenses:Utilities:Phone",
    "SIMPLISAFE": "Expenses:Security",
    "COMMERCE INSURANCE": "Expenses:Insurance",
    "MILFORDREALESTATE": "Expenses:Housing:Rent",
    "STUDNTLOAN": "Expenses:Debt:StudentLoan",
}

MONTHS = {
    "JAN":"01","FEB":"02","MAR":"03","APR":"04",
    "MAY":"05","JUN":"06","JUL":"07","AUG":"08",
    "SEP":"09","OCT":"10","NOV":"11","DEC":"12"
}

current_account = "Assets:Unknown"
pending_description = ""

def categorize(desc, amount):
    d = desc.upper()

    for key, acct in RULES.items():
        if key in d:
            return acct

    if amount < 0:
        return "Expenses:Unknown"
    else:
        return "Income:Unknown"


for line in sys.stdin:

    line = line.rstrip()

    # detect account section
    for acctname in ACCOUNT_MAP:
        if acctname in line:
            current_account = ACCOUNT_MAP[acctname]

    # match transaction line
    m = re.match(r'^(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)(\d{2})\s+(.*?)(-?\d[\d,]*\.\d{2})\s+\d', line)

    if m:

        month = MONTHS[m.group(1)]
        day = m.group(2)
        desc = m.group(3).strip()
        amount = float(m.group(4).replace(",", ""))

        date = f"{YEAR}-{month}-{day}"

        category = categorize(desc, amount)

        print(f"{date} {desc}")

        if amount < 0:
            amt = abs(amount)

            print(f"    {category:<30} {amt:.2f}")
            print(f"    {current_account:<30} {-amt:.2f}")

        else:
            print(f"    {current_account:<30} {amount:.2f}")
            print(f"    {category:<30} {-amount:.2f}")

        print(f"    ; {desc}")
        print()
