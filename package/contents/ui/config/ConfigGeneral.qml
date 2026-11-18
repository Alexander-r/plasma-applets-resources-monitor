import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCMUtils

KCMUtils.SimpleKCM {
    property alias cfg_updateInterval: updateIntervalSpinBox.realValue
    property alias cfg_fontScale: fontScale.value
    property alias cfg_showCpuMonitor: showCpuMonitor.checked
    property alias cfg_showNetMonitor: showNetMonitor.checked
    property alias cfg_showClock: showClock.checked
    property alias cfg_showRamMonitor: showRamMonitor.checked
    property alias cfg_memoryInPercent: memoryInPercent.checked
    property alias cfg_verticalLayout: verticalLayout.checked
    property alias cfg_enableHints: enableHints.checked
    property alias cfg_enableShadows: enableShadows.checked

    Kirigami.FormLayout {
        RowLayout {
            Kirigami.FormData.label: i18n('Update interval:')
            DecimalSpinBox {
                id: updateIntervalSpinBox
                decimals: 1
                realStepSize: 0.1
                realFrom: 0.1
                realTo: 3600
            }
            QQC2.Label {
                text: i18nc('Abbreviation for seconds', 's')
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n('Font scale:')
            QQC2.SpinBox {
                id: fontScale
                from: 1
                to: 100
                editable: true
            }
            QQC2.Label {
                text: i18nc('Percent', '%')
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: showCpuMonitor
            Kirigami.FormData.label: i18n('CPU:')
            text: i18n('Show CPU monitor')
        }

        QQC2.CheckBox {
            id: showClock
            text: i18n('Show clock')
            enabled: showCpuMonitor.checked
        }

        QQC2.CheckBox {
            id: showRamMonitor
            Kirigami.FormData.label: i18n('Memory:')
            text: i18n('Show RAM monitor')
        }

        QQC2.CheckBox {
            id: memoryInPercent
            text: i18n('Memory in percentage')
            enabled: showRamMonitor.checked
        }

        QQC2.CheckBox {
            id: showNetMonitor
            Kirigami.FormData.label: i18n('Network:')
            text: i18n('Show network monitor')
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: verticalLayout
            Kirigami.FormData.label: i18n('Appearance:')
            text: i18n('Vertical layout')
        }

        QQC2.CheckBox {
            id: enableHints
            text: i18n('Enable hints')
        }

        QQC2.CheckBox {
            id: enableShadows
            text: i18n('Drop shadows')
        }
    }
}
