/*
 * Copyright (C) 2012 Robin Burchell <robin+nemo@viroteck.net>
 * Copyright (C) 2017 Chupligin Sergey <neochapay@gmail.com>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * Neither the name of Nemo Mobile nor the names of its contributors
 *     may be used to endorse or promote products derived from this
 *     software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

import QtQuick 2.6

import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

import Nemo.Dialogs 1.0

import org.nemomobile.folderlistmodel 1.0
import org.nemomobile.filemuncher 1.0

Page {
    id: page
    property alias path: dirModel.path
    property bool isRootDirectory: false
    property string selectedFile
    property string selectedFilePath
    property int selectedRow

    headerTools:  HeaderToolsLayout {
        title: qsTr("File manager")

        tools: [
            ToolButton{
                iconSource: "image://theme/chevron-left"
                onClicked: pageStack.pop()
                visible: !page.isRootDirectory
            },
            ToolButton {
                iconSource: "image://theme/refresh"
                onClicked: dirModel.refresh()
            },
            ToolButton {
                iconSource: "image://theme/bars"
                onClicked: (pageMenu.status == DialogStatus.Closed) ? pageMenu.open() : pageMenu.close()
            }
        ]
        drawerLevels: []
    }


    Rectangle {
        id: header
        height: window.inPortrait ? 72 : 0
        visible: window.inPortrait ? true : false
        color: "#EA650A"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        property alias content: othercontent.children

        Item {
            id: othercontent
            width: childrenRect.width
            height: childrenRect.height
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }

        Label {
            id: label
            anchors.left: othercontent.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            smooth: true
            color: "white"
            text: dirModel.path
            elide: Text.ElideLeft
        }
    }

    ListView {
        id: fileList
        width: parent.width
        height: parent.height
        anchors.fill: parent
        clip: true

        model: FolderListModel {
            id: dirModel
        }
        delegate: FileListDelegate {
            onClicked: {
                if (model.isDir)
                    window.cdInto(model.filePath)
                else {
                    page.selectedFilePath = model.filePath
                    openFileDialog.visible = true
                }
            }
        }
    }

    Label {
        text: qsTr("No files here")
        anchors.centerIn: parent
        visible: !dirModel.awaitingResults && fileList.count == 0 ? true : false
    }

    Spinner {
        anchors.centerIn: parent
        visible: dirModel.awaitingResults && fileList.count == 0 ? true : false
    }

    // TODO: create menus only when needed, and share between pages
    /*Menu {
        id: pageMenu
        MenuLayout {
                MenuItem { text: "Delete items"; onClicked: {
                    var component = Qt.createComponent("FilePickerSheet.qml");
                    if (component.status == Component.Ready) {
                        // TODO: error handling
                        var deletePicker = component.createObject(page, {"model": dirModel, "pickText": "Delete"});
                        deletePicker.picked.connect(function(files) {
                            console.log("deleting " + files)
                            dirModel.rm(files)
                        });
                        deletePicker.open()
                    } else {
                        console.log("Delete Items: " + component.errorString())
                    }
                }
            }
            MenuItem {
                text: "Create new folder"
                onClicked: {
                    var component = Qt.createComponent("InputSheet.qml");
                    if (component.status == Component.Ready) {
                        // TODO: error handling
                        var newFolder = component.createObject(page, {"title": "Enter new folder name"});
                        newFolder.accepted.connect(function() {
                            var folderName = newFolder.inputText
                            console.log("Creating new folder " + folderName)
                            dirModel.mkdir(folderName)
                        });
                        newFolder.open()
                    }
                }
            }
        }
    }*/

    /*Menu {
        id: tapMenu
        MenuLayout {
            MenuItem {
                text: "Details"
                onClicked: {
                    var component = Qt.createComponent("DetailViewSheet.qml");
                    console.log(component.errorString())
                    if (component.status == Component.Ready) {
                        // TODO: error handling
                        var detailsSheet = component.createObject(page, {"model": dirModel, "selectedRow": page.selectedRow});
                        detailsSheet.open()
                    }
                }
            }

            MenuItem {
                text: "Delete"
                onClicked: dirModel.rm(selectedFile)
            }
        }
    }*/

    QueryDialog {
        id: openFileDialog
        headingText: qsTr("Open file")
        subLabelText: page.selectedFilePath
        acceptText: qsTr("Yes")
        cancelText: qsTr("No")
        onAccepted: {
            Qt.openUrlExternally("file://" + page.selectedFilePath )
        }
        visible: false
    }

    QueryDialog {
        id: errorDialog
        acceptText: qsTr("Ok")
        visible: false
    }

    Connections {
        target: dirModel
        onError: {
            errorDialog.headingText = errorTitle
            errorDialog.subLabelText = errorMessage
            errorDialog.open()
        }
    }

}

