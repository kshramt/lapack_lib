# Constants
DIR := $(abspath .)
DEPS := fort

LIB_NAMES = lapack

export MY_PYTHON ?= python3
PYTHON := $(MY_PYTHON)
export MY_RUBY ?= ruby2
RUBY := $(MY_RUBY)

export MY_ERB ?= erb
ERB := $(MY_ERB)
ERB_FLAGS := -T '-' -P

export MY_FC ?= gfortran
FC := $(MY_FC)

export MY_FFLAG_COMMON ?= gfortran
FFLAG_COMMON := $(MY_FFLAG_COMMON)

export MY_FFLAG_DEBUG ?= -fbounds-check -O0 -fbacktrace -ffpe-trap=invalid,zero,overflow -ggdb -pg -DDEBUG
FFLAG_DEBUG := $(MY_FFLAG_DEBUG)

export MY_LAPACK ?= -lopenblas
LAPACK := $(MY_LAPACK)

FFLAGS := $(FFLAG_COMMON) $(FFLAG_DEBUG) $(LAPACK)

# Configurations
.SUFFIXES:
.DELETE_ON_ERROR:
.SECONDARY: $(LIB_NAMES:%=%_lib_test.exe) $(LIB_NAMES:%=%_lib.o) $(LIB_NAMES:%=%_lib.mod)
# $(LIB_NAMES:%=%_lib_test.o) $(LIB_NAMES:%=%_lib.o) $(LIB_NAMES:%=%_lib.mod)
.ONESHELL:
export SHELL := /bin/bash
export SHELLOPTS := pipefail:errexit:nounset:noclobber

# Tasks
.PHONY: all test deps prepare
all: prepare
test: prepare $(LIB_NAMES:%=%_lib_test.exe.done)
prepare: deps $(LIB_NAMES:%=%_lib.f90)
deps: $(DEPS:%=dep/%.updated)

lapack_lib_test.exe: lapack_interface_lib.mod lapack_interface_lib.o lapack_constant_lib.mod lapack_constant_lib.o
lapack_lib.mod lapack_lib.o: lapack_interface_lib.mod lapack_constant_lib.mod
lapack_interface_lib.mod lapack_interface_lib.o: lapack_constant_lib.mod

# Files

%_test.exe: %.o %.mod %_test.o
	$(FC) $(FFLAGS) -o $@ $(filter-out %.mod,$^)

# Rules

%_test.exe.done: %_test.exe
	./$<
	touch $@
%_lib.mod %_lib.o: %_lib.f90
	$(FC) $(FFLAGS) -c -o $(@:%.mod=%.o) $<
	touch ${@:%.o=%.mod}
%_test.o: %_test.f90 %.mod
	$(FC) $(FFLAGS) -c -o $(@:%.mod=%.o) $<
%.o: %.f90
	$(FC) $(FFLAGS) -c -o $(@:%.mod=%.o) $<
%.f90: %.f90.erb lapack_lib_util.rb dep/fort/lib/fort/type.rb
	export RUBYLIB=dep/fort/lib:$(DIR):"$${RUBYLIB}"
	$(ERB) $(ERB_FLAGS) $< >| $@

define DEPS_RULE_TEMPLATE =
dep/$(1)/%: | dep/$(1).updated ;
endef
$(foreach f,$(DEPS),$(eval $(call DEPS_RULE_TEMPLATE,$(f))))

dep/%.updated: config/dep/%.ref dep/%.synced
	cd $(@D)/$*
	git fetch origin
	git merge "$$(cat ../../$<)"
	cd -
	if [[ -r dep/$*/Makefile ]]; then
	   $(MAKE) -C dep/$*
	fi
	touch $@

dep/%.synced: config/dep/%.uri | dep/%
	cd $(@D)/$*
	git remote rm origin
	git remote add origin "$$(cat ../../$<)"
	cd -
	touch $@

$(DEPS:%=dep/%): dep/%:
	git init $@
	cd $@
	git remote add origin "$$(cat ../../config/dep/$*.uri)"
