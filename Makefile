bulman: bulma.css bulman.sh
	cat bulman.sh bulma.css > bulman
	chmod +x bulman

clean:
	rm bulman

test: bulman
	man mktemp | ./bulman
