class DownloadableInstallerComponent extends FileInstallerComponentBase {
    downloadUrl := ""

    __New(appName, version, downloadUrl, zipped, destPath, appState, stateKey, cache, versionSorter, parentStateKey := "", overwrite := false, tmpDir := "", onlyCompiled := false) {
        this.zipped := zipped
        this.downloadUrl := downloadUrl
        super.__New(appName, version, destPath, appState, stateKey, cache, versionSorter, parentStateKey, overwrite, tmpDir, onlyCompiled)
    }

    InstallFilesAction() {
        destPath := this.zipped ? this.tmpDir . "\" . this.tmpFile : this.GetDestPath()

        downloadUrl := this.GetDownloadUrl()

        if (downloadUrl == "") {
            throw AppException("Failed to determine download URL of installer component " . this.stateKey)
        }

        Download(this.GetDownloadUrl(), destPath)

        if (this.zipped) {
            this.zipFile := destPath
        }

        return true
    }

    GetDownloadUrl() {
        return this.downloadUrl
    }
}
