class CopyableInstallerComponent extends FileInstallerComponentBase {
    sourcePath := ""
    deleteZip := false
    testFile := ""

    __New(appName, version, sourcePath, zipped, destPath, appState, stateKey, cache, versionSorter, parentStateKey := "", overwrite := false, tmpDir := "", onlyCompiled := false, testFile := "") {
        this.testFile := testFile
        this.zipped := zipped
        this.sourcePath := sourcePath
        super.__New(appName, version, destPath, appState, stateKey, cache, versionSorter, parentStateKey, overwrite, tmpDir, onlyCompiled)
    }

    InstallFilesAction() {
        if (this.zipped) {
            this.zipFile := this.sourcePath
        } else {
            FileCopy(this.sourcePath, this.destPath, this.overwrite)
        }

        return true
    }

    GetSourcePath() {
        return this.sourcePath
    }

    ExistsAction() {
        exists := super.ExistsAction()

        if (exists && this.testFile) {
            return (!!FileExist(this.destPath . "\" . this.testFile))
        }

        return exists
    }
}
