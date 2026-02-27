import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtMultimedia 5.12
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
        muted: true 
        autoPlay: true
        playbackRate: 1.0

        onStopped: {
            if (playbackState === MediaPlayer.StoppedState) {
                seek(0)
                play()
            }
        }

        playlist: Playlist {
            playbackMode: Playlist.Loop
            PlaylistItem { source: config.VideoBackground }
        }
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        opacity: mediaPlayer.hasVideo ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        fillMode: VideoOutput.PreserveAspectCrop
        source: mediaPlayer
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
