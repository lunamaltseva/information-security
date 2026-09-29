#!/usr/bin/env python3
"""Render the simulated phishing-lure email (email_template.html) to a PDF.

Part of Lab 04 - Phishing Awareness Simulation (training material only).

Usage (from the Lab4 directory, inside the venv):

    . .venv/bin/activate
    python email/build_pdf.py
"""

import os
from weasyprint import HTML

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "email_template.html")
OUT = os.path.join(os.path.dirname(HERE), "phishing_simulation_email.pdf")


def main() -> None:
    HTML(filename=SRC).write_pdf(OUT)
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
