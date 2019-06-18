#
# Prepare openapi files and run projects in containers.
#
YAML=$(shell find * -name \*yaml)
YAMLSRC=$(shell find openapi -name \*yaml.src)
YAMLGEN=$(patsubst %.yaml.src,%.yaml,$(YAMLSRC))

yaml: $(YAMLGEN)

.ONESHELL:
%.yaml: %.yaml.src
	tox -e yamllint -- -d relaxed $<
	tox -e yaml 2>/dev/null --  $< $@ 

yamllint: $(YAML)
	tox -e yamllint -- $<

python-generate: openapi/simple.yaml
	test -f scripts/swagger-codegen-cli-3.0.9.jar || wget -o scripts/swagger-codegen-cli-3.0.9.jar https://oss.sonatype.org/content/repositories/snapshots/io/swagger/codegen/v3/swagger-codegen-cli/3.0.9-SNAPSHOT/swagger-codegen-cli-3.0.9-20190617.162503-27.jar 
	java -jar scripts/swagger-codegen-cli.jar generate -l python-flask -i  openapi/simple.yaml -o src

python-flask: python-flask-generate
	(cd python-flask && docker-compose up --build test )

python-flask-quickstart: python-flask-generate
	# Test all
	(cd python-flask && docker-compose up --build test )
	# Build and run the application
	(cd python-flask && docker-compose up simple )

