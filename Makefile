ifndef GEM_HOME
  $(error GEM_HOME not set.)
endif

PACKAGES := philote
VERSION_FILE := lib/philote/version.rb

DEPS := ${GEM_HOME}/installed
VERSION := $(shell sed -ne '/.*VERSION *= *"\(.*\)".*/s//\1/p' <$(VERSION_FILE))
GEMS := $(addprefix pkg/, $(addsuffix -$(VERSION).gem, $(PACKAGES)))

export RUBYLIB := lib:test:$(RUBYLIB)

all: test $(GEMS)

console: $(DEPS)
	irb -r 'philote'

test: $(DEPS)
	cutest ./test/**/*_test.rb

clean:
	rm pkg/*.gem

release: $(GEMS)
	git tag v$(VERSION)
	git push --tags
	for gem in $^; do gem push $$gem; done

pkg/%-$(VERSION).gem: %.gemspec $(VERSION_FILE) | pkg
	gem build $<
	mv $(@F) pkg/

$(DEPS): $(GEM_HOME) .gems
	cat .gems | xargs gem install && touch $(GEM_HOME)/installed

pkg $(GEM_HOME):
	mkdir -p $@

.PHONY: all test release clean
