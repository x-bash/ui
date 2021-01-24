time jq .[].testers[].received_events_url <json-data/b.json
time json.extract \* testers \* received_events_url <json-data/b.json
time bash jp<json-data/b.json | grep \"received_events_url\"\]

