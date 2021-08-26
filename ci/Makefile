PROJECT := python-native
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
SHA1 := $(shell git rev-parse --verify HEAD)

# General commands
.PHONY: help
BOLD=\e[1m
RESET=\e[0m

help:
	@echo -e "${BOLD}SYNOPSIS${RESET}"
	@echo -e "\tmake <target> [NOCACHE=1]"
	@echo
	@echo -e "${BOLD}DESCRIPTION${RESET}"
	@echo -e "\ttest build inside docker container to have a reproductible build."
	@echo
	@echo -e "${BOLD}MAKE TARGETS${RESET}"
	@echo -e "\t${BOLD}help${RESET}: display this help and exit."
	@echo
	@echo -e "\t${BOLD}<stage>${RESET}: build <stage> docker images for ALL DISTROS."
	@echo -e "\t${BOLD}<distro>_<stage>${RESET}: build <stage> docker image for a specific distro."
	@echo -e "\t${BOLD}save_<stage>${RESET}: Save <stage> docker images for ALL DISTROS."
	@echo -e "\t${BOLD}save_<distro>_<stage>${RESET}: Save the <stage> docker image for a specific distro."
	@echo -e "\t${BOLD}sh_<distro>_<stage>${RESET}: run a container using the <stage> docker image specified (debug purpose)."
	@echo
	@echo -e "\tWith ${BOLD}<stage>${RESET}:"
	@echo -e "\t\t${BOLD}env${RESET}"
	@echo -e "\t\t${BOLD}devel${RESET}"
	@echo -e "\t\t${BOLD}build${RESET}"
	@echo -e "\t\t${BOLD}test${RESET}"
	@echo -e "\t\t${BOLD}install_env${RESET}"
	@echo -e "\t\t${BOLD}install_devel${RESET}"
	@echo -e "\t\t${BOLD}install_build${RESET}"
	@echo -e "\t\t${BOLD}install_test${RESET}"
	@echo -e "\te.g. 'make build'"
	@echo
	@echo -e "\tWith amd64 (x86_64) ${BOLD}<distro>${RESET}:"
	@echo -e "\t\t${BOLD}amd64_alpine${RESET} (edge)"
	@echo -e "\t\t${BOLD}amd64_archlinux${RESET} (latest)"
	@echo -e "\t\t${BOLD}amd64_centos${RESET} (latest)"
	@echo -e "\t\t${BOLD}amd64_debian${RESET} (latest)"
	@echo -e "\t\t${BOLD}amd64_fedora${RESET} (latest)"
	@echo -e "\t\t${BOLD}amd64_opensuse${RESET} (tumbleweed)"
	@echo -e "\t\t${BOLD}amd64_ubuntu${RESET} (rolling)"
	@echo -e "\te.g. 'make amd64_ubuntu_test'"
	@echo
	@echo -e "\tWith aarch64 ${BOLD}<distro>${RESET}:"
	@echo -e "\t\t${BOLD}arm64v8_alpine${RESET} (latest)"
	@echo -e "\t\t${BOLD}arm64v8_centos${RESET} (latest)"
	@echo -e "\t\t${BOLD}arm64v8_debian${RESET} (latest)"
	@echo -e "\t\t${BOLD}arm64v8_fedora${RESET} (latest)"
	@echo -e "\t\t${BOLD}arm64v8_ubuntu${RESET} (latest)"
	@echo -e "\t\t${BOLD}arm64v8_manylinux${RESET} (latest)"
	@echo -e "\te.g. 'make arm64v8_ubuntu_test'"
	@echo
	@echo -e "\t${BOLD}clean${RESET}: Remove cache and ALL docker images."
	@echo -e "\t${BOLD}clean_<distro>${RESET}: Remove cache and docker images for the specified distro."
	@echo
	@echo -e "\t${BOLD}NOCACHE=1${RESET}: use 'docker build --no-cache' when building container (default use cache)."
	@echo
	@echo -e "branch: $(BRANCH)"
	@echo -e "sha1: $(SHA1)"

# Need to add cmd_distro to PHONY otherwise target are ignored since they do not
# contain recipe (using FORCE do not work here)
.PHONY: all
all: build

# Delete all implicit rules to speed up makefile
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =
# Keep all intermediate files
# ToDo: try to remove it later
.SECONDARY:

# Docker image name prefix.
IMAGE := ${PROJECT}

ifdef NOCACHE
DOCKER_BUILD_CMD := docker build --no-cache
else
DOCKER_BUILD_CMD := docker build
endif

DOCKER_RUN_CMD := docker run --rm --init --net=host

# Currently supported distro
DISTROS = alpine centos debian fedora ubuntu
STAGES = env devel build test install_env install_devel install_build install_test

# $* stem
# $< first prerequist
# $@ target name

export/%:
	-mkdir -pv $@

##################
## AMD64 STAGES ##
##################
AMD_DISTROS = $(addprefix amd64_, $(DISTROS) archlinux opensuse)
define make-stage-target =
#$$(info STAGE: amd64_$1)
#$$(info Create targets: amd64_$1 $(addsuffix _$1, $(AMD_DISTROS)).)
targets_$1 = $(addsuffix _$1, $(AMD_DISTROS))
.PHONY: amd64_$1 $$(targets_$1)
amd64_$1: $$(targets_$1)
$$(targets_$1): amd64_%_$1: docker/amd64/%/Dockerfile
	#@docker image rm -f ${IMAGE}:amd64_$$*_$1 2>/dev/null
	${DOCKER_BUILD_CMD} --target=$1 --tag ${IMAGE}:amd64_$$*_$1 -f $$< ..

#$$(info Create targets: save_amd64_$1 $(addprefix save_, $(addsuffix _$1, $(AMD_DISTROS))) (debug).)
save_targets_$1 = $(addprefix save_, $(addsuffix _$1, $(AMD_DISTROS)))
.PHONY: save_amd64_$1 $$(save_targets_$1)
save_amd64_$1: $$(save_targets_$1)
$$(save_targets_$1): save_amd64_%_$1: cache/amd64/%/docker_$1.tar
cache/amd64/%/docker_$1.tar: amd64_%_$1
	@rm -f $$@
	mkdir -p cache/amd64/$$*
	docker save ${IMAGE}:amd64_$$*_$1 -o $$@

#$$(info Create targets: $(addprefix sh_, $(addsuffix _$1, $(AMD_DISTROS))) (debug).)
sh_targets_$1 = $(addprefix sh_, $(addsuffix _$1, $(AMD_DISTROS)))
.PHONY: $$(sh_targets_$1)
$$(sh_targets_$1): sh_amd64_%_$1: amd64_%_$1
	${DOCKER_RUN_CMD} -it --name ${IMAGE}_amd64_$$*_$1 ${IMAGE}:amd64_$$*_$1

#$$(info Create targets: $(addprefix clean_, $(addsuffix _$1, $(AMD_DISTROS))).)
clean_targets_$1 = $(addprefix clean_, $(addsuffix _$1, $(AMD_DISTROS)))
.PHONY: clean_amd64_$1 $$(clean_targets_$1)
clean_amd64_$1: $$(clean_targets_$1)
$$(clean_targets_$1): clean_amd64_%_$1:
	docker image rm -f ${IMAGE}:amd64_$$*_$1 2>/dev/null
	rm -f cache/amd64/$$*/docker_$1.tar
endef

$(foreach stage,$(STAGES),$(eval $(call make-stage-target,$(stage))))


################
## ARM STAGE  ##
################
ARM_DISTROS = $(addprefix arm64v8_, $(DISTROS) manylinux)
define make-arm-stage-target =
#$$(info STAGE: arm64v8_$1)
#$$(info Create targets: arm64v8_$1 $(addsuffix _$1, $(ARM_DISTROS)).)
targets_$1 = $(addsuffix _$1, $(ARM_DISTROS))
.PHONY: arm64v8_$1 $$(targets_$1)
arm64v8_$1: $$(targets_$1)
$$(targets_$1): arm64v8_%_$1: docker/arm64v8/%/Dockerfile
	$$(info you may need to run: "docker run --rm --privileged multiarch/qemu-user-static --reset -p yes")
	#@docker image rm -f ${IMAGE}:arm64v8_$$*_$1 2>/dev/null
	${DOCKER_BUILD_CMD} --target=$1 --tag ${IMAGE}:arm64v8_$$*_$1 -f $$< ..

#$$(info Create targets: save_arm64v8_$1 $(addprefix save_, $(addsuffix _$1, $(ARM_DISTROS))) (debug).)
save_targets_$1 = $(addprefix save_, $(addsuffix _$1, $(ARM_DISTROS)))
.PHONY: save_arm64v8_$1 $$(save_targets_$1)
save_arm64v8_$1: $$(save_targets_$1)
$$(save_targets_$1): save_arm64v8_%_$1: cache/arm64v8/%/docker_$1.tar
cache/arm64v8/%/docker_$1.tar: arm64v8_%_$1
	@rm -f $$@
	mkdir -p cache/arm64v8/$$*
	docker save ${IMAGE}:arm64v8_$$*_$1 -o $$@

#$$(info Create targets: $(addprefix sh_, $(addsuffix _$1, $(ARM_DISTROS))) (debug).)
sh_targets_$1 = $(addprefix sh_, $(addsuffix _$1, $(ARM_DISTROS)))
.PHONY: $$(sh_targets_$1)
$$(sh_targets_$1): sh_arm64v8_%_$1: arm64v8_%_$1
	${DOCKER_RUN_CMD} -it --name ${IMAGE}_arm64v8_$$*_$1 ${IMAGE}:arm64v8_$$*_$1

#$$(info Create targets: $(addprefix clean_, $(addsuffix _$1, $(ARM_DISTROS))).)
clean_targets_$1 = $(addprefix clean_, $(addsuffix _$1, $(ARM_DISTROS)))
.PHONY: clean_arm64v8_$1 $$(clean_targets_$1)
clean_arm64v8_$1: $$(clean_targets_$1)
$$(clean_targets_$1): clean_arm64v8_%_$1:
	docker image rm -f ${IMAGE}:arm64v8_$$*_$1 2>/dev/null
	rm -f cache/arm64v8/$$*/docker_$1.tar
endef

$(foreach stage,$(STAGES),$(eval $(call make-arm-stage-target,$(stage))))

## MERGE ##
define make-stage-target =
#$$(info STAGE: $1)
.PHONY: $1
$1: amd64_$1 arm64v8_$1

endef

$(foreach stage,$(STAGES),$(eval $(call make-tage-target,$(stage))))
## CLEAN ##
clean_amd64_targets = $(addprefix clean_, $(AMD_DISTROS))
clean_arm64v8_targets = $(addprefix clean_, $(ARM_DISTROS))
.PHONY: clean $(clean_amd64_targets) $(clean_arm64v8_targets)
clean: $(clean_amd64_targets) $(clean_arm64v8_targets)
	docker container prune -f
	docker image prune -f
	-rmdir cache
$(clean_amd64_targets): clean_amd64_%: $(addprefix clean_amd64_%_, $(STAGES))
	-rmdir cache/amd64/$*
$(clean_arm64v8_targets): clean_arm64v8_%: $(addprefix clean_arm64v8_%_, $(STAGES))
	-rmdir cache/arm64v8/$*

.PHONY: distclean
distclean: clean
	-docker container rm -f $$(docker container ls -aq)
	-docker image rm -f $$(docker image ls -aq)
