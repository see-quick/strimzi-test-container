PROJECT_NAME=test-container

spotbugs: systemtest_make

systemtest_make:
	$(MAKE) -C systemtest $(MAKECMDGOALS)

pushtonexus:
    ./.travis/push-to-nexus.sh