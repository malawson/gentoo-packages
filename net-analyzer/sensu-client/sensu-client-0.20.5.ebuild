# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils user

DESCRIPTION="Monitoring for today's infrastructure."
HOMEPAGE="https://sensuapp.org/"

SRC_URI="https://github.com/sensu/sensu/archive/v${PV}.tar.gz"

LICENSE="MIT"
SLOT="0.20.5"
KEYWORDS="~amd64"
IUSE=""

# Sensu-client has some gem dependencies
DEPEND=""


S=${WORKDIR}/sensu-${PV}

ROOT_DIR="/usr/local"
INSTALL_DIR=${ROOT_DIR}
PKG_NAME="sensu-client-${PV}"

pkg_setup(){
	#setup sensu server group and user

	enewgroup sensu
	enewuser sensu -1 -1 /usr/local/sensu-client sensu
}

src_install() {

	dodir "${INSTALL_DIR}"
	mv "${S}" "${D}${INSTALL_DIR}/${PKG_NAME}" || die "install failed"
	chown -Rf sensu:sensu "${D}${INSTALL_DIR}"
}

pkg_postinst() {
	if [[ ! -L ${INSTALL_DIR}/sensu-client ]] ; then
		einfo "Creating symbolic link: sensu-client -> ${PKG_NAME}"
		cd ${INSTALL_DIR} && rm -rf sensu-client && ln -s ${PKG_NAME} sensu-client
	else
		einfo "${INSTALL_DIR}/sensu-client already appears to be a link"
	fi
	
}
