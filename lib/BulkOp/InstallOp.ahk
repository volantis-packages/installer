class InstallOp extends BulkOperationBase {
    installers := ""
    progressTitle := "Installing..."
    progressText := "Please wait while installation finishes..."
    successMessage := "Finished installing."
    failedMessage := "{n} requirements(s) could not be installed due to errors."

    __New(app, installers, owner := "") {
        this.installers := installers
        super.__New(app, owner)
    }

    RunAction() {
        if (this.useProgress) {
            this.progress.SetRange(0, this.CountInstallerItems())
        }

        for index, name in this.installers {
            name := "installer." . name
            installer := this.app[name]

            if (!HasBase(installer, InstallerBase.Prototype)) {
                throw AppException("Provided installer is not valid: " . name)
            }

            this.StartItem(installer.name, installer.name . " running...")
            this.results[name] := this.RunInstallerAction(installer)
            this.FinishItem(installer.name, true, installer.name . " finished.")
        }
    }

    RunInstallerAction(installer) {
        return installer.InstallOrUpdate(this.progress)
    }

    CountInstallerItems() {
        return HasBase(this.installers, Array.Prototype) ? this.installers.Length : this.installers.Count
    }
}
