.PHONY : all

all : clean
	make test

bulman : bulma.css bulman.sh
	cat bulman.sh bulma.css > bulman
	chmod +x bulman

test : bulman
	man mktemp | ./bulman

clean :
	rm bulman
