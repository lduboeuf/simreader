/*
 * Copyright (C) 2015 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Telephony.PhoneNumber 0.1 as PhoneNumber
import Ubuntu.Telephony 0.1

import MeeGo.QOfono 0.2

Item {

    id: root
    property int simNb: 0

    property string path

    height: simInfoList.height
    width: parent.width

    function getCountryCode() {
            var localeName = Qt.locale().name
            return localeName.substr(localeName.length - 2, 2)
    }

    PhoneUtils {
        id: phoneUtils
    }

    OfonoSimManager {
        id: simMng
        modemPath: path
    }

    Column {
        id:simInfoList
        width: parent.width

        SimItem {
            color: UbuntuColors.blue
            title.text: i18n.tr("SIM #%1").arg(simNb+1)
            title.color: theme.palette.normal.raised //always white to provide better contrast on blue background
        }

        SimItem {
            title.text: simMng.subscriberNumbers[0] === undefined ? i18n.tr("empty") : simMng.subscriberNumbers[0]
            subtitle.text: i18n.tr("SubscriberNumber")
            Button {
                anchors.right: parent.right
                anchors.rightMargin: units.gu(2)
                anchors.verticalCenter: parent.verticalCenter
                text: i18n.tr("change number")
                onClicked: PopupUtils.open(dialog)
            }
        }
        SimItem {
            title.text: simMng.subscriberIdentity === undefined ? i18n.tr("empty") : simMng.subscriberIdentity
            subtitle.text: i18n.tr("SubscriberIdentity (IMSI)")
        }
        SimItem {
            title.text: simMng.mobileCountryCode === undefined ? i18n.tr("empty") : simMng.mobileCountryCode
            subtitle.text: i18n.tr("MobileCountryCode (MCC)")
        }
        SimItem {
            title.text: simMng.mobileNetworkCode === undefined ? i18n.tr("empty") : simMng.mobileNetworkCode
            subtitle.text: i18n.tr("MobileNetworkCode (MNC)")
        }
        SimItem {
            title.text: simMng.cardIdentifier
            subtitle.text: i18n.tr("CardIdentifier (ICCID)")
        }
//        SimItem {
//            title.text: JSON.stringify(simMng.serviceNumbers)
//            subtitle.text: i18n.tr("ServiceNumbers")
//        }

    }

    Component {
        id: dialog
        Dialog {
            id: dialogue
            title: i18n.tr("SubscriberNumber Change")
            text: i18n.tr("Insert your international phone number")
            property bool secondConfirmation: false
            Label {
                id: feedbackText
                color: "red"
                visible: text.length > 0
            }

            PhoneNumber.PhoneNumberField {
                id: newNumber
                text: simMng.subscriberNumbers[0].length > 0 ? simMng.subscriberNumbers[0]: undefined
                autoFormat: true
                placeholderText: "+33 6 00 00 00 00"
                defaultRegion: getCountryCode()
                updateOnlyWhenFocused: false
                inputMethodHints: Qt.ImhDialableCharactersOnly

            }
            Row {
                id: row
                width: parent.width
                spacing: units.gu(1)
                Button {
                    width: parent.width/2 - row.spacing/2
                    text: i18n.tr("Cancel")
                    onClicked: PopupUtils.close(dialogue)
                }
                Button {
                    width: parent.width/2 - row.spacing/2
                    text: i18n.tr("Confirm")
                    color: UbuntuColors.green
                    onClicked: {

                       phoneUtils.setCountryCode(getCountryCode())
                       var valid = phoneUtils.isPhoneNumber(newNumber.text) && newNumber.text[0] === "+"
                       if (!valid) {
                           feedbackText.text = i18n.tr("Wrong number format")
                       } else {

                           if (secondConfirmation) {
                               simMng.subscriberNumbers = [phoneUtils.normalizePhoneNumber(newNumber.text)]
                               PopupUtils.close(dialogue)
                           }else{
                               secondConfirmation = true
                               dialogue.text=""
                               newNumber.enabled = false
                               feedbackText.text = i18n.tr("Your phonenumber seems to be OK, confirm again to write it")
                               feedbackText.wrapMode = Text.WordWrap
                               feedbackText.color = "green"
                           }
                       }
                    }
                }
            }
        }
    }
}
//Q_PROPERTY(bool present READ present NOTIFY presenceChanged)
//   Q_PROPERTY(QString subscriberIdentity READ subscriberIdentity NOTIFY subscriberIdentityChanged)
//   Q_PROPERTY(QString mobileCountryCode READ mobileCountryCode NOTIFY mobileCountryCodeChanged)
//   Q_PROPERTY(QString mobileNetworkCode READ mobileNetworkCode NOTIFY mobileNetworkCodeChanged)
//   Q_PROPERTY(QString serviceProviderName READ serviceProviderName NOTIFY serviceProviderNameChanged)
//   Q_PROPERTY(QStringList subscriberNumbers READ subscriberNumbers WRITE setSubscriberNumbers NOTIFY subscriberNumbersChanged)
//   Q_PROPERTY(QVariantMap serviceNumbers READ serviceNumbers NOTIFY serviceNumbersChanged)
//   Q_PROPERTY(PinType pinRequired READ pinRequired NOTIFY pinRequiredChanged)
//   Q_PROPERTY(QVariantList lockedPins READ lockedPins NOTIFY lockedPinsChanged)
//   Q_PROPERTY(QString cardIdentifier READ cardIdentifier NOTIFY cardIdentifierChanged)
//   Q_PROPERTY(QStringList preferredLanguages READ preferredLanguages NOTIFY preferredLanguagesChanged)
//   Q_PROPERTY(QVariantMap pinRetries READ pinRetries NOTIFY pinRetriesChanged)
//   Q_PROPERTY(bool fixedDialing READ fixedDialing NOTIFY fixedDialingChanged)
//   Q_PROPERTY(bool barredDialing READ barredDialing NOTIFY barredDialingChanged)
