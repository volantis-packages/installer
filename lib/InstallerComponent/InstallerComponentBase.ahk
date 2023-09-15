class InstallerComponentBase {
    appName := ""
    appState := ""
    cache := ""
    stateKey := ""
    parentStateKey := ""
    scriptFile := ""
    scriptDir := ""
    overwrite := false
    tmpDir := ""
    tmpFile := ""
    version := ""
    onlyCompiled := false
    _versionSorter := ""

    __New(appName, version, appState, stateKey, cache, versionSorter, parentStateKey := "", overwrite := false, tmpDir := "", onlyCompiled := false) {
        this.appName := appName
        this.version := version
        this.cache := cache
        this._versionSorter := versionSorter

        if (!tmpDir) {
            tmpDir := A_Temp . "\" . appName . "\Installers"
        }

        if (this.tmpFile == "") {
            this.tmpFile := "Installer" . Random()
        }


        this.stateKey := stateKey
        this.appState := appState
        this.overwrite := overwrite

        SplitPath(A_ScriptFullPath, &scriptFile, &scriptDir)
        this.scriptFile := scriptFile
        this.scriptDir := scriptDir
        this.tmpDir := tmpDir
        this.onlyCompiled := onlyCompiled

        DirCreate(tmpDir)
    }

    /**
    * ABSTRACT METHODS
    */

    ExistsAction() {
        throw MethodNotImplementedException("InstallerComponentBase", "ExistsAction")
    }

    InstallAction() {
        throw MethodNotImplementedException("InstallerComponentBase", "InstallAction")
    }

    UninstallAction() {
        throw MethodNotImplementedException("InstallerComponentBase", "UninstallAction")
    }

    CleanupPreviousVersionsAction() {
        return true ; Cleanup is optional
    }

    /**
    * IMPLEMENTED METHODS
    */

    Exists() {
        if (this.onlyCompiled && !A_IsCompiled) {
            return true
        }

        exists := this.ExistsAction()

        return (exists && this.appState.GetVersion(this.stateKey) != "" && this.appState.IsComponentInstalled(this.stateKey))
    }

    Install() {
        if (this.onlyCompiled && !A_IsCompiled) {
            return true
        }

        this.CleanupPreviousVersionsAction()
        this.InstallAction()
        this.appState.SetVersion(this.stateKey, this.version)
        this.appState.SetComponentInstalled(this.stateKey, true)

        return true
    }

    CleanupPreviousVersions() {
        if (this.onlyCompiled && !A_IsCompiled) {
            return true
        }

        this.CleanupPreviousVersionsAction()
        return true
    }

    Uninstall() {
        if (this.onlyCompiled && !A_IsCompiled) {
            return true
        }

        this.UninstallAction()

        this.appState.RemoveVersion(this.stateKey)
        this.appState.SetComponentInstalled(this.stateKey, false)

        return true
    }

    IsOutdated() {
        if (this.onlyCompiled && !A_IsCompiled) {
            return false
        }

        isOutdated := true

        if (this.Exists()) {
            componentVersion := this.appState.GetVersion(this.stateKey)
            isOutdated := this._versionSorter.IsOutdated(componentVersion, this.version)
        }

        this.appState.SetLastUpdateCheck(this.stateKey)

        return isOutdated
    }

    GetParentVersion() {
        return this.appState.GetVersion(this.parentStateKey)
    }
}
