export REQS_MAP="500 1000 5000"
export API_MAP="json xml pdf"

echo ">>> RAW"
run_raw "raw_json" "http://gateway.docker:9001/1.json";
run_raw "raw_xml" "http://gateway.docker:9002/1.xml";
run_raw "raw_pdf" "http://gateway.docker:9003/1.pdf";

echo ">>> NGINX"
run "nginx" "http://gateway.docker:9101/api/{api}/1";

echo ">>> KRAKEND S"
run "krakend_s" "http://gateway.docker:9103/api/{api}/1";

echo ">>> KRAKEND F"
run "krakend_f" "http://gateway.docker:9104/api/{api}/1";

echo ">>> NODE"
run "node" "http://gateway.docker:9105/api/{api}/1";

echo ">>> SPRING"
run "spring" "http://gateway.docker:9102/api/{api}/1";