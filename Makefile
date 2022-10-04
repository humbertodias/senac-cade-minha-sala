install-dep:
	apt install curl jq sqlite3
	pip install sqlite-utils
	npm install -g http-server --no-package-lock

run:
	http-server .

db:
	rm *.db
	./db.sh