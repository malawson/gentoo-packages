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

# Sensu-server depends on rabbitmq and redis, using upstream ones

DEPEND=">=net-misc/rabbitmq-server-3.2.4
		 =dev-db/redis-2.6.12"

RDEPEND="{DEPEND}"

S=${WORKDIR}/sensu-${PV}

ROOT_DIR="/usr/local"
INSTALL_DIR=${ROOT_DIR}
PKG_NAME="sensu-server-${PV}"

pkg_setup(){
	#setup sensu server group and user

	enewgroup sensu
	enewuser sensu -1 -1 /usr/local/sensu-server sensu
}

src_install() {

	dodir "${INSTALL_DIR}"
	mv "${S}" "${D}${INSTALL_DIR}/${PKG_NAME}" || die "install failed"
	chown -Rf sensu:sensu "${D}${INSTALL_DIR}"
}

pkg_postinst() {
	if [[ ! -L ${INSTALL_DIR}/sensu-server ]] ; then
		einfo "Creating symbolic link: sensu-server -> ${PKG_NAME}"
		cd ${INSTALL_DIR} && rm -rf sensu-server && ln -s ${PKG_NAME} sensu-server
	else
		einfo "${INSTALL_DIR}/sensu-server already appears to be a link"
	fi

}
