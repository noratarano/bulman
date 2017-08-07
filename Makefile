.PHONY : all

all : clean test

bulman : program.sh bulma.css template.html parseManpage.js
	./program.sh template.html bulma.css parseManpage.js > bulman
	chmod +x bulman

test : bulman
	man mktemp | ./bulman

clean :
	rm -f bulman
