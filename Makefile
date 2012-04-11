test:
	@prove -lvr

install:
	@./nodebrew setup

.PHONY: test install
