import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCMUtils

KCMUtils.SimpleKCM {
    property alias cfg_networkSensorDownload: networkSensorDownload.text
    property alias cfg_downloadMaxMbps: downloadMaxMbps.realValue
    property alias cfg_networkSensorUpload: networkSensorUpload.text
    property alias cfg_uploadMaxMbps: uploadMaxMbps.realValue

    Kirigami.FormLayout {
        QQC2.TextField {
            id: networkSensorDownload
            Kirigami.FormData.label: i18n('Network download sensor:')
            placeholderText: 'network/all/download'
            Layout.preferredWidth: Kirigami.Units.gridUnit * 20
        }

        RowLayout {
            Kirigami.FormData.label: i18n('Max download speed:')
            DecimalSpinBox {
                id: downloadMaxMbps
                decimals: 1
                realStepSize: 0.5
                realFrom: 0.5
                realTo: 100000
            }
            QQC2.Label {
                text: i18nc('Abbreviation for Mbit/s', 'Mbit/s')
            }
        }

        QQC2.TextField {
            id: networkSensorUpload
            Kirigami.FormData.label: i18n('Network upload sensor:')
            placeholderText: 'network/all/upload'
            Layout.preferredWidth: Kirigami.Units.gridUnit * 20
        }

        RowLayout {
            Kirigami.FormData.label: i18n('Max upload speed:')
            DecimalSpinBox {
                id: uploadMaxMbps
                decimals: 1
                realStepSize: 0.5
                realFrom: 0.5
                realTo: 100000
            }
            QQC2.Label {
                text: i18nc('Abbreviation for Mbit/s', 'Mbit/s')
            }
        }

        QQC2.Label {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 20
            wrapMode: Text.WordWrap
            font: Kirigami.Theme.smallFont
            text: i18n('Sensor ids come from ksystemstats, e.g. "network/all/download" for all interfaces or "network/<interface>/download" for one. Run "kstatsviewer --list" to see the available sensors.')
        }
    }
}
