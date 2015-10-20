# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils user

DESCRIPTION="Gorgeous metric viz, dashboards & editors for Graphite, InfluxDB & OpenTSDB"
HOMEPAGE="http://grafana.org"

SRC_URI="https://grafanarel.s3.amazonaws.com/builds/grafana-${PV}.linux-x64.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""


DEPEND="
	>=net-libs/nodejs-0.12
	>=dev-lang/go-1.3.3
"

RDEPEND="${DEPEND}"


S=${WORKDIR}/grafana-${PV}

ROOT_DIR="/usr/local"
INSTALL_DIR=${ROOT_DIR}
PKG_NAME="grafana-${PV}"

pkg_setup(){

	enewgroup grafana
	enewuser grafana -1 -1 /usr/local/grafana grafana
}

src_install() {

	
	dodir "${INSTALL_DIR}"
	mv "${S}" "${D}${INSTALL_DIR}/${PKG_NAME}" || die "install failed"
	chown -Rf grafana:grafana "${D}${INSTALL_DIR}"


}

pkg_postinst() {

	if [[ ! -L ${INSTALL_DIR}/grafana ]] ; then
		einfo "Creating symbolic link: grafana -> ${PKG_NAME}"
		cd ${INSTALL_DIR} && rm -rf grafana && ln -s ${PKG_NAME} grafana
	else
		einfo "${INSTALL_DIR}/grafana already appears to be a link"
	fi

}

