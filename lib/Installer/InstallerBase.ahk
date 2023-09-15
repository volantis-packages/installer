; This represents an object that can install a component of LauncherGen, or a launcher itself.
class InstallerBase {
    name := "Installer"
    appName := ""
    cache := ""
    onlyInstallWhenCompiled := false
    version := ""
    appState := ""
    stateKey := ""
    installerComponents := []
    scriptFile := ""
    scriptDir := ""
    tmpDir := ""
    parentComponent := ""
    installerType := ""
    _versionSorter := ""

    static INSTALLER_TYPE_REQUIREMENT := "requirement"
    static INSTALLER_TYPE_UPDATE := "update"
    static INSTALLER_TYPE_SELF_UPDATE := "self_update"

    __New(appName, version, appState, stateKey, cacheManager, cacheName, versionSorter, components := "", tmpDir := "", cleanupFiles := "") {
        this.appName := appName
        this.cache := cacheManager[cacheName]
        this.version := version
        this.appState := appState
        this.stateKey := stateKey
        SplitPath(A_ScriptFullPath, &scriptFile, &scriptDir)
        this.scriptFile := scriptFile
        this.scriptDir := scriptDir
        this._versionSorter := versionSorter

        if (!HasBase(cleanupFiles, Array.Prototype)) {
            cleanupFiles := [cleanupFiles]
        }

        this.cleanupFiles := cleanupFiles

        if (tmpDir == "") {
            tmpDir := A_Temp . "\" . appName . "\Installers"
        }

        this.tmpDir := tmpDir

        if (components != "") {
            this.addComponents(components)
        }
    }

    /**
    * IMPLEMENTED METHODS
    */

    AddComponents(components) {
        if (!HasBase(components, Array.Prototype)) {
            components := [components]
        }

        for index, component in components {
            this.installerComponents.push(component)
        }
    }

    InstallOrUpdate(progress := "") {
        if (this.onlyInstallWhenCompiled && !A_IsCompiled) {
            return true
        }

        return this.IsInstalled() ? this.Update(progress) : this.Install(progress)
    }

    CountComponents() {
        return this.installerComponents.Length
    }

    Install(progress := "") {
        if (this.onlyInstallWhenCompiled && !A_IsCompiled) {
            return true
        }

        this.appState.SetVersion(this.stateKey, this.version)
        success := true

        if (progress != "") {
            progress.SetDetailText(this.name . " components installing...")
        }

        for index, component in this.installerComponents {
            if (progress != "") {
                progress.IncrementValue(1, this.name . " installing " . component.stateKey . "...")
            }

            if (!component.Exists() || component.IsOutdated()) {
                componentSuccess := component.Install()

                if (!componentSuccess) {
                    success := false
                }
            }
        }

        for index, cleanupFile in this.cleanupFiles {
            if (FileExist(cleanupFile)) {
                FileDelete(cleanupFile)
            }
        }

        this.appState.SetComponentInstalled(this.stateKey, success)

        return success
    }

    IsInstalled() {
        if (this.onlyInstallWhenCompiled && !A_IsCompiled) {
            return true
        }

        for index, component in this.installerComponents {
            if (!component.Exists()) {
                return false
            }
        }

        return (this.appState.IsComponentInstalled(this.stateKey))
    }

    Update(progress := "") {
        if (this.onlyInstallWhenCompiled && !A_IsCompiled) {
            return true
        }

        if (this.IsOutdated()) {
            this.Install(progress) ; Ideally update the install before calling super.Update() so that this doesn't run.
        }
    }

    IsOutdated() {
        isOutdated := true

        if (this.IsInstalled()) {
            installedVersion := this.appState.GetVersion(this.stateKey)
            isOutdated := (this._versionSorter.IsOutdated(installedVersion, this.version))
        }

        if (!isOutdated) {
            for index, component in this.installerComponents {
                if (component.IsOutdated()) {
                    isOutdated := true
                }
            }
        }

        return isOutdated
    }

    Uninstall(progress := "") {
        if (this.onlyInstallWhenCompiled && !A_IsCompiled) {
            return true
        }

        if (progress != "") {
            progress.SetDetailText(this.name . ": Uninstalling components")
        }

        for index, component in this.installerComponents {
            if (progress != "") {
                progress.IncrementValue(1)
            }

            component.Uninstall()
        }

        this.appState.RemoveVersion(this.stateKey)
        this.appState.SetComponentInstalled(this.stateKey, false)
        return true
    }
}
