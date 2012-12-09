test:
	@prove -lvr t

install:
	@./nodebrew setup

.PHONY: test install
