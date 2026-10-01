#!/bin/bash
echo "Directories in the collection:"
find case -type d
echo ""
echo "Size of the collection:"
du -sh case
echo "Log files:"
ls case/logs
echo ""

echo "Regular Files"
find . -type f | wc -l
echo "Done."
