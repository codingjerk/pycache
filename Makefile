all: lint typecheck test coverage quality benchmark build

.PHONY: test lint typecheck coverage quality benchmark build deploy all

package = pycache

test:
	@echo [ === TEST === ]
	@python3 -m pytest --quiet --benchmark-disable

lint:
	@echo [ === LINT === ]
	@python3 -m pycodestyle $(package)
	@python3 -m pylint --disable=W1116 $(package)
	@python3 -m pycodestyle tests
	@python3 -m pylint --disable=C0114,C0116,E0401,W0611 tests

typecheck:
	@echo [ === TYPECHECK === ]
	@python3 -m mypy --strict --pretty --no-error-summary $(package)
	@python3 -m mypy --strict --pretty --no-error-summary --allow-untyped-decorators tests

coverage:
	@echo [ === COVERAGE === ]
	@PYTHONPATH=. python3 -m pytest --cov=$(package) --cov-fail-under=100 --cov-report=term-missing:skip-covered --benchmark-disable --quiet

quality:
	@echo [ === QUALITY === ]
	@! radon mi $(package)/**.py | grep -v " - A"
	@! radon cc $(package)/**.py | grep -vP "\.py"$ | grep -v " - A"

benchmark:
	@echo [ === BENCHMARK === ]
	@python3 -m pytest --quiet --benchmark-only --benchmark-save=benchmark

benchmark_compare:
	@echo [ === BENCHMARK === ]
	@python3 -m pytest --quiet --benchmark-only --benchmark-compare

build:
	@echo [ === BUILD === ]
	@python3 setup.py -q sdist bdist

deploy:
	@echo [ === DEPLOY === ]
	@rm -rf dist/$(package)-*.linux-x86_64.tar.gz
	@python3 -m twine upload dist/$(package)-*.tar.gz
