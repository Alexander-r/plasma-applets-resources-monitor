import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls
import org.kde.kcmutils as KCMUtils

KCMUtils.SimpleKCM {
    property alias cfg_networkDownloadDiagramColor: networkDownloadDiagramColor.color
    property alias cfg_networkUploadDiagramColor: networkUploadDiagramColor.color

    Kirigami.FormLayout {
        KQuickControls.ColorButton {
            id: networkUploadDiagramColor
            showAlphaChannel: true
            Kirigami.FormData.label: i18n('Network upload diagram color:')
        }

        KQuickControls.ColorButton {
            id: networkDownloadDiagramColor
            showAlphaChannel: true
            Kirigami.FormData.label: i18n('Network download diagram color:')
        }
    }
}
