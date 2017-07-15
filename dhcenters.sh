# Check dependencies
if ! command -v hxnormalize >/dev/null 2>&1 ; then
  echo "This script depends on html-xml-utils, which doesn't seem to be available on the system.";
  exit 0;
fi

# Actual work
lastpage=$(wget http://dhcenternet.org/centers -o /dev/null -O -|grep "last page"|sed 's/last\ page/\n/'|tail -1|sed 's/page=/\n/'|tail -1|cut -d\" -f1)

echo "Center,Location" > dhcenters.csv
for i in $(seq 0 $lastpage); do
  wget "http://dhcenternet.org/centers?page=$i" -O "$i.html" 
  cat $i.html |hxnormalize -x -l 1000|hxselect tbody|hxselect div.views-field-realname|hxselect span.field-content|sed 's/<span/\n\<span/g'|grep -v ^$ > "$i.names"
  for a in $(seq 1 $(cat $i.names|wc -l)); do cat $i.names|head -n$a|tail -n1|hxselect -c a|html2text -utf8 -width 1000; done > $i.parsednames
  cat $i.html |hxnormalize -x -l 1000|hxselect tbody|hxselect div.views-field-field-location|grep field-content > "$i.locations"
  for a in $(seq 1 $(cat $i.locations|wc -l)); do l=$(cat $i.locations|head -n$a|tail -n1|hxselect -c div|html2text -utf8 -width 1000); echo "$l"; done> $i.parsedlocations
  for a in $(seq 1 $(cat $i.names|wc -l)); do 
    name=$(cat $i.parsednames|head -n$a|tail -n1); 
    loc=$(cat $i.parsedlocations|head -n$a|tail -n1); 
    echo -e "\"$name\",\"$loc\"" >> dhcenters.csv; 
  done
done
