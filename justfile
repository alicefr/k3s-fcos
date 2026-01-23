image := "localhost/fcos-k3s"
base := "quay.io/fedora/fedora-coreos:43.20251214.3.0"
archive := "fcos.ociarchive"

build:
    sudo podman build --no-cache --build-arg BASE={{base}} -t {{image}} -f Containerfile .

oci-archive:
    sudo skopeo copy containers-storage:{{image}} oci-archive:{{archive}}

cosa_function := '''
    #!/usr/bin/env bash
    cosa() {
        env | grep COREOS_ASSEMBLER || true

        # Default container image
        COREOS_ASSEMBLER_CONTAINER_LATEST="quay.io/coreos-assembler/coreos-assembler:latest"
        sudo podman pull $COREOS_ASSEMBLER_CONTAINER_LATEST

        set -ex
        sudo podman run --rm -ti --security-opt=label=disable --privileged -u 0 \
				--network host \
            -v=${PWD}:/srv/ --device=/dev/kvm --device=/dev/fuse \
            --tmpfs=/tmp -v=/var/tmp:/var/tmp --name=cosa \
            ${COREOS_ASSEMBLER_CONFIG_GIT:+-v=$COREOS_ASSEMBLER_CONFIG_GIT:/srv/src/config/:ro} \
            ${COREOS_ASSEMBLER_GIT:+-v=$COREOS_ASSEMBLER_GIT/src/:/usr/lib/coreos-assembler/:ro} \
            ${COREOS_ASSEMBLER_ADD_CERTS:+-v=/etc/pki/ca-trust:/etc/pki/ca-trust:ro} \
            ${COREOS_ASSEMBLER_CONTAINER_RUNTIME_ARGS} \
            ${COREOS_ASSEMBLER_CONTAINER:-$COREOS_ASSEMBLER_CONTAINER_LATEST} "$@"
    }
'''

qemu:
    #!/usr/bin/env bash
    {{cosa_function}}
    rm -rf cache
    mkdir -p cache
    cp {{archive}} cache/{{archive}}
    cd cache
    cosa init --force https://github.com/coreos/fedora-coreos-config
    cosa import oci-archive:/srv/{{archive}}
    cosa osbuild qemu

azure:
    #!/usr/bin/env bash
    {{cosa_function}}
    rm -rf cache
    mkdir -p cache
    cp {{archive}} cache/{{archive}}
    cd cache
    cosa init --force https://github.com/coreos/fedora-coreos-config
    cosa import oci-archive:/srv/{{archive}}
    cosa osbuild azure
