import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtMultimedia
import "components"

Item {
    id: root

    FontLoader {
        id: mainFont
        source: config.FontFile
    }

    height: Screen.height
    width: Screen.width

        Image {
            id: background
            anchors.fill: parent
            height: parent.height
            width: parent.width
            fillMode: Image.PreserveAspectCrop
    
            source: config.Background
    
            asynchronous: false
            cache: true
            mipmap: true
            clip: true
            visible: true
        }
        
        MediaPlayer {
            id: mediaPlayer
            source: config.VideoBackground
            loops: MediaPlayer.Infinite
            videoOutput: videoOutput
        }
    
        VideoOutput {
            id: videoOutput
            anchors.fill: parent
            opacity: mediaPlayer.hasVideo ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            fillMode: VideoOutput.PreserveAspectCrop
            visible: mediaPlayer.hasVideo
        }
    

    Item {
        id: contentPanel

        anchors {
            fill: parent
            topMargin: config.Padding
            rightMargin: config.Padding
            bottomMargin:config.Padding
            leftMargin: config.Padding
        }

        DateTimePanel {
            id: dateTimePanel

            anchors {
                top: parent.top
                left: parent.left
            }
        }
        
        LoginPanel {
            id: loginPanel
            
            anchors.fill: parent
        }
    }
}
