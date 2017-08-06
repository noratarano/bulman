.PHONY : all

all : clean
	make test

bulman : bulma.css program.sh
	cat program.sh bulma.css > bulman
	chmod +x bulman

test : bulman
	man mktemp | ./bulman

clean :
	rm bulman
