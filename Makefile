# Constants
DIR := $(abspath .)
DEPS := fort fortran_lib

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

export MY_LAPACK ?= -lblas
LAPACK := $(MY_LAPACK)

FFLAGS := $(FFLAG_COMMON) $(FFLAG_DEBUG) $(LAPACK)

MY_CPP ?= cpp
CPP := $(MY_CPP)
CPP_FLAGS := -P -C
ifeq ($(FC),ifort)
   CPP_FLAGS += -D __INTEL_COMPILER
endif

FILES := $(shell git ls-files)
F90_NAMES := $(patsubst %.f90,%,$(filter %.f90,$(FILES)))
F90_NAMES += $(patsubst %.f90.erb,%,$(filter %.f90.erb,$(FILES)))
LIB_NAMES := $(filter %_lib,$(F90_NAMES))
TEST_NAMES := $(filter %_test,$(F90_NAMES))
ERRORTEST_TEMPLATE_NAMES := $(filter %_errortest,$(F90_NAMES))
ERRORTEST_STEMS := $(patsubst %_errortest,%,$(ERRORTEST_TEMPLATE_NAMES))
ERRORTEST_IMPL_NAMES := $(foreach name,$(ERRORTEST_TEMPLATE_NAMES),$(filter $(name)/%,$(F90_NAMES)))
ERRORTEST_NAMES := $(addsuffix _errortest,$(subst _errortest/,_,$(ERRORTEST_IMPL_NAMES)))
EXE_NAMES := $(filter-out $(LIB_NAMES) $(TEST_NAMES) $(ERRORTEST_TEMPLATE_NAMES) $(ERRORTEST_IMPL_NAMES),$(F90_NAMES))

# Functions
o_mod = $(1:%=%.o) $(addsuffix .mod,$(filter %_lib,$(1)))

# Configurations
.SUFFIXES:
.DELETE_ON_ERROR:
.ONESHELL:
export SHELL := /bin/bash
export SHELLOPTS := pipefail:errexit:nounset:noclobber

# Tasks
.PHONY: all src test deps prepare
all: prepare src $(EXE_NAMES:%=bin/%.exe)
src: prepare $(patsubst %,src/%.f90,$(filter-out $(ERRORTEST_TEMPLATE_NAMES) $(ERRORTEST_IMPL_NAMES),$(F90_NAMES))) $(patsubst %,src/%.f90,$(ERRORTEST_NAMES))
test: prepare $(TEST_NAMES:%=test/%.exe.tested) $(ERRORTEST_NAMES:%=test/%.exe.tested) test/lapack_lib_util.rb.tested
prepare: deps
deps: $(DEPS:%=dep/%.updated)

# Files

lapack_lib.f90: lapack_lib_util.rb

## Executables

## Tests
test/lapack_lib_test.exe: $(call o_mod,comparable_lib lapack_constant_lib lapack_interface_lib lapack_lib lapack_lib_test)

test/lapack_lib_util.rb.tested: lapack_lib_util.rb
	mkdir -p $(@D)
	$(RUBY) $<
	touch $@

src/comparable_lib.f90: dep/fortran_lib/src/comparable_lib.f90
	mkdir -p $(@D)
	cp -f $< $@


# Rules
define ERRORTEST_F90_TEMPLATE =
$(1)_$(2)_errortest.f90: $(1)_errortest.f90 $(1)_errortest/$(2).f90
	mkdir -p $$(@D)
	{
	   cat $$^
	   echo '   stop'
	   echo 'end program main'
	} >| $$@
endef
$(foreach stem,$(ERRORTEST_STEMS),$(foreach branch,$(patsubst $(stem)_%_errortest,%,$(filter $(stem)_%,$(ERRORTEST_NAMES))),$(eval $(call ERRORTEST_F90_TEMPLATE,$(stem),$(branch)))))

test/%_errortest.exe.tested: test/%_errortest.exe
	cd $(@D)
	! ./$(<F)
	touch $(@F)
test/%_test.exe.tested: test/%_test.exe
	cd $(@D)
	./$(<F)
	touch $(@F)
test/%.exe:
	mkdir -p $(@D)
	$(FC) $(FFLAGS) -o $@ $(filter-out %.mod,$^)


bin/%.exe:
	mkdir -p $(@D)
	$(FC) $(FFLAGS) -o $@ $(filter-out %.mod,$^)


%_lib.mod %_lib.o: src/%_lib.f90
	$(FC) $(FFLAGS) -c -o $*_lib.o $<
	touch $*_lib.mod
%.o: src/%.f90
	$(FC) $(FFLAGS) -c -o $*.o $<


src/%.f90: %.f90 lapack_lib.h
	mkdir -p $(@D)
	$(CPP) $(CPP_FLAGS) $< $@
%.f90: %.f90.erb
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
