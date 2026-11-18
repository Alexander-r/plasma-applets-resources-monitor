pkgname=plasma-applets-resources-monitor
pkgver=r32.e057616
pkgrel=1
pkgdesc='Plasmoid for monitoring CPU, memory, network traffic, GPUs, disks and batteries (ksystemstats only, no helper processes)'
arch=(any)
url=https://github.com/Alexander-r/plasma-applets-resources-monitor
license=(GPL-3.0-or-later)
depends=(
    kcmutils
    kde-cli-tools     # kstart, for the click action
    kirigami
    kitemmodels
    kquickcharts
    ksystemstats      # data source for all sensors
    libksysguard
    libplasma
    plasma-workspace  # application picker in the settings
    plasma5support
    qt6-declarative
)
makedepends=(
    cmake
    extra-cmake-modules
    kpackage
)
source=('git+https://github.com/Alexander-r/plasma-applets-resources-monitor.git')
sha256sums=('SKIP')

pkgver() {
  cd "$pkgname"
  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

build() {
    local cmake_options=(
        -B build
        -S $pkgname
        -W no-author
        -D CMAKE_INSTALL_PREFIX=/usr
    )
    cmake "${cmake_options[@]}"
    cmake --build build
}

package() {
    DESTDIR="$pkgdir" cmake --install build
}
