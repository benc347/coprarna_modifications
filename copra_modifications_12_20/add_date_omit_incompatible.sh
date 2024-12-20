
# make help list for webserver
echo "## last updated:" | tr '\n' ' ' > Date.txt; date >> Date.txt
cat Date.txt ../head.txt > fullhead.txt
cat fullhead.txt CopraRNA_available_organisms.tmp > CopraRNA_available_organisms.txt
rm CopraRNA_available_organisms.tmp fullhead.txt Date.txt

