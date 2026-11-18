import QtQuick
import QtQuick.Controls as QQC2

// QtQuick.Controls 2 SpinBox only handles integers; this scales a real value.
QQC2.SpinBox {
    id: spinBox

    property int decimals: 1
    property real realValue: 0
    property real realFrom: 0
    property real realTo: 100
    property real realStepSize: 1

    readonly property int factor: Math.pow(10, decimals)

    from: Math.round(realFrom * factor)
    to: Math.round(realTo * factor)
    stepSize: Math.max(1, Math.round(realStepSize * factor))
    value: Math.round(realValue * factor)
    editable: true

    onValueModified: realValue = value / factor

    validator: DoubleValidator {
        bottom: spinBox.realFrom
        top: spinBox.realTo
        decimals: spinBox.decimals
        notation: DoubleValidator.StandardNotation
    }

    textFromValue: (value, locale) => Number(value / spinBox.factor).toLocaleString(locale, 'f', spinBox.decimals)
    valueFromText: (text, locale) => Math.round(Number.fromLocaleString(locale, text) * spinBox.factor)
}
