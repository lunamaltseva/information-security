touch grass
echo """#!/bin/bash
echo \"New line at \$\(date\)\" >> grass""" >> write_line.sh
chmod +x write_line.sh

sudo crontab -u $(whoami) -e << echo "* * * * * $(pwd)/write_line.sh"