pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "."

Singleton {
    id: root

    property bool isRecording: false
    property bool paused: false
    property string videosDir: Quickshell.env("HOME") + "/Videos/Recordings"
    property string currentOutput: ""
    property string lastError: ""
    property bool overlayVisible: false
    property string overlayMode: "region"
    property int overlayRequestSerial: 0
    property bool recordAudioOutput: false
    property bool recordAudioInput: false
    property string pendingCommand: ""

    function shellQuote(value) {
        return "'" + String(value).replace(/'/g, "'\\''") + "'";
    }

    function timestamp() {
        const d = new Date();
        const pad = n => String(n).padStart(2, "0");
        return d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate()) + "-" + pad(d.getHours()) + "-" + pad(d.getMinutes()) + "-" + pad(d.getSeconds());
    }

    function nextPath() {
        return videosDir + "/Recording_" + timestamp() + ".mp4";
    }

    function start(mode) {
        startWithAudio(mode, false, false);
    }

    function startWithAudio(mode, recordAudioOutput, recordAudioInput) {
        if (isRecording) return;

        const normalizedMode = (mode === "screen" || mode === "portal" || mode === "region") ? mode : "region";
        if (normalizedMode === "region") {
            requestOverlay();
            root.recordAudioOutput = recordAudioOutput;
            root.recordAudioInput = recordAudioInput;
            return;
        }

        startPrepared(normalizedMode, "", recordAudioOutput, recordAudioInput);
    }

    function startPrepared(mode, region, recordAudioOutput, recordAudioInput) {
        if (isRecording) return;

        const outputPath = nextPath();
        currentOutput = outputPath;
        lastError = "";

        let recorder = "gpu-screen-recorder -f 60";
        if (mode === "portal") {
            recorder += " -w portal";
        } else if (mode === "screen") {
            recorder += " -w screen";
        } else {
            recorder += " -w region -region " + shellQuote(region);
        }

        const audioSources = [];
        if (recordAudioOutput) audioSources.push("default_output");
        if (recordAudioInput) audioSources.push("default_input");
        if (audioSources.length === 1) {
            recorder += " -a " + audioSources[0];
        } else if (audioSources.length > 1) {
            recorder += " -a " + shellQuote(audioSources.join("|"));
        }

        recorder += " -o " + shellQuote(outputPath);

        let command = "mkdir -p " + shellQuote(videosDir) + " && notify-send " + shellQuote("Screen Recorder") + " " + shellQuote("Starting recording...");
        command += " && " + recorder;

        pendingCommand = command;
        isRecording = true;
        paused = false;
        overlayVisible = false;
        startDelay.restart();
    }

    function requestOverlay() {
        if (isRecording) {
            stop();
            return;
        }

        overlayMode = "region";
        overlayRequestSerial += 1;
        overlayVisible = true;
        ScreenshotService.refreshWindows();
    }

    function cancelOverlay() {
        overlayVisible = false;
    }

    function setOverlayMode(mode) {
        overlayMode = (mode === "window" || mode === "screen") ? mode : "region";
        if (overlayMode === "window") {
            ScreenshotService.refreshWindows();
        }
    }

    function toggleAudioOutput() {
        recordAudioOutput = !recordAudioOutput;
    }

    function toggleAudioInput() {
        recordAudioInput = !recordAudioInput;
    }

    function startGeometry(x, y, w, h) {
        if (w < 4 || h < 4) {
            cancelOverlay();
            return;
        }

        const region = Math.round(w) + "x" + Math.round(h) + "+" + Math.round(x) + "+" + Math.round(y);
        startPrepared("region", region, recordAudioOutput, recordAudioInput);
    }

    function startScreen() {
        startPrepared("screen", "", recordAudioOutput, recordAudioInput);
    }

    function stop() {
        if (!isRecording) return;
        stopProcess.running = true;
    }

    function togglePause() {
        if (!isRecording) return;

        if (paused) {
            resumeProcess.running = true;
            paused = false;
        } else {
            pauseProcess.running = true;
            paused = true;
        }
    }

    function toggle() {
        if (isRecording) {
            stop();
        } else {
            requestOverlay();
        }
    }

    Timer {
        id: startDelay
        interval: 420
        repeat: false
        onTriggered: {
            startProcess.command = ["sh", "-c", root.pendingCommand];
            startProcess.running = true;
        }
    }

    Process {
        id: startProcess

        stderr: StdioCollector {
            id: recorderError
        }

        onExited: exitCode => {
            const wasRecording = root.isRecording;
            root.isRecording = false;
            root.paused = false;
            if (exitCode === 0 || exitCode === 130 || exitCode === 2) {
                if (wasRecording) {
                    notifyDoneProcess.command = ["notify-send", "Screen Recorder", "Recording saved to " + root.currentOutput];
                    notifyDoneProcess.running = true;
                }
                return;
            }

            root.lastError = recorderError.text.trim();
            notifyErrorProcess.command = ["notify-send", "-u", "critical", "Screen Recorder", root.lastError || "Recording failed"];
            notifyErrorProcess.running = true;
        }
    }

    Process {
        id: stopProcess
        command: ["sh", "-c", "pkill -SIGCONT -f '^gpu-screen-recorder'; pkill -SIGINT -f '^gpu-screen-recorder'"]
    }

    Process {
        id: pauseProcess
        command: ["pkill", "-SIGSTOP", "-f", "^gpu-screen-recorder"]
    }

    Process {
        id: resumeProcess
        command: ["pkill", "-SIGCONT", "-f", "^gpu-screen-recorder"]
    }

    Process {
        id: notifyDoneProcess
    }

    Process {
        id: notifyErrorProcess
    }
}
