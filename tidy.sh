find . -name "*pl" -exec perltidy -b '{}' \;
find . -name "*pm" -exec perltidy -b '{}' \;
find . -name "*cgi" -exec perltidy -b '{}' \;
find . -name "*bak" -exec rm -rf '{}' \;
