OCAMLBUILD=ocamlbuild
OCAMLBUILD_OPTS=-use-menhir -use-ocamlfind -menhir "menhir --explain" -pkg unix -pkg str

TARGET=genqbf

.PHONY: all clean demo

all:
	$(OCAMLBUILD) $(OCAMLBUILD_OPTS) $(TARGET).native

clean:
	rm -f $(TARGET).native *~ \#*
	$(OCAMLBUILD) -clean

demo: all
	./genqbf.native -I I.bool -R R.bool -Q P.bool