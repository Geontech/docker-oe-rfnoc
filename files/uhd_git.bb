require recipes-support/uhd/uhd.inc

LIC_FILES_CHKSUM = "file://LICENSE;md5=8255adf1069294c928e0e18b01a16282"

PV = "3.10.1.1"

SRC_URI = "git://github.com/EttusResearch/uhd.git;branch=rfnoc-devel \
          file://fix_block_id.patch \
          file://fix_log.patch \
          "

SRCREV = "89427e8cbb35c435e67f60efec5c56e26867c60c"

S = "${WORKDIR}/git/host"
