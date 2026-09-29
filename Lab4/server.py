#!/usr/bin/env python3
"""
Lab 04 - Phishing Awareness Simulation
======================================

*** THIS IS A PHISHING SIMULATION FOR A CYBERSECURITY COURSE. ***
*** It is a teaching tool only. Do NOT deploy it publicly and   ***
*** do NOT enter real credentials into it.                      ***

A tiny Flask app that mimics the login page of a MADE-UP social
network ("Friendzy") to demonstrate, in a controlled classroom
setting, how a credential-harvesting page works and why users
should recognise the warning signs.

Every page is loudly labelled "PHISHING SIMULATION" and the login
form warns the visitor not to type real credentials. When the form
is submitted, the server records the submission to a plainly named
file (captured_submissions.txt) and then immediately redirects the
visitor to a debrief page that explains that they just fell for a
simulated phish and lists the red flags they should have caught.

Run (from the Lab4 directory, inside the provided venv):

    . .venv/bin/activate
    python server.py

Then open http://127.0.0.1:5000/ in a browser.

By default the server binds to localhost ONLY so the simulation is
never exposed to other machines on the network.
"""

import os
from datetime import datetime, timezone

from flask import (
    Flask,
    render_template,
    request,
    redirect,
    url_for,
)

app = Flask(__name__)

# The name of the made-up brand used throughout the simulation.
BRAND = "Friendzy"

# Where submitted form data is recorded. Named plainly and openly:
# this is a teaching artifact, not a covert harvester.
CAPTURE_FILE = os.path.join(os.path.dirname(__file__), "captured_submissions.txt")


def record_submission(username: str, password: str) -> None:
    """Append one simulated 'capture' to the log file.

    In a real awareness campaign you would typically log only THAT a
    user submitted (not the secret itself). We record the raw fields
    here purely to make the classroom demonstration concrete -- and
    the page itself repeatedly warns visitors never to type a real
    password. Never reuse this pattern outside an authorised lab.
    """
    entry = (
        "=== PHISHING SIMULATION - captured submission ===\n"
        f"timestamp : {datetime.now(timezone.utc).isoformat()}\n"
        f"source_ip : {request.remote_addr}\n"
        f"user_agent: {request.headers.get('User-Agent', '-')}\n"
        f"username  : {username!r}\n"
        f"password  : {password!r}\n"
        "-------------------------------------------------\n\n"
    )
    with open(CAPTURE_FILE, "a", encoding="utf-8") as fh:
        fh.write(entry)


@app.route("/")
def index():
    """Serve the fake (clearly labelled) login page."""
    return render_template("login.html", brand=BRAND)


@app.route("/login", methods=["POST"])
def login():
    """Pretend to log the user in: record the submission, then debrief."""
    username = request.form.get("username", "")
    password = request.form.get("password", "")
    record_submission(username, password)
    # We deliberately do NOT echo the captured values back to the browser.
    return redirect(url_for("awareness"))


@app.route("/awareness")
def awareness():
    """The reveal: explain that this was a simulation and teach the tells."""
    return render_template("awareness.html", brand=BRAND)


if __name__ == "__main__":
    host = os.environ.get("HOST", "127.0.0.1")  # localhost only by default
    port = int(os.environ.get("PORT", "5000"))
    print("\n" + "=" * 60)
    print("  PHISHING SIMULATION - cybersecurity course lab")
    print("  Educational use only. Do not enter real credentials.")
    print(f"  Submissions are logged to: {CAPTURE_FILE}")
    print("=" * 60 + "\n")
    app.run(host=host, port=port, debug=True)
