install-dep:
	apt install curl jq sqlite3
	pip install sqlite-utils
	npm install -g http-server --no-package-lock

run:
	rm -f senac-cade-minha-sala
	ln -s . senac-cade-minha-sala
	http-server . -g -i -o senac-cade-minha-sala

db:
	rm *.db
	./db.sh