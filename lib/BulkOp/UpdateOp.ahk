class UpdateOp extends InstallOp {
    progressTitle := "Updating..."
    progressText := "Please wait while the update is completed..."
    successMessage := "Finished updating."
    failedMessage := "However, there were errors during the update process. You might need to reinstall the application."

    RunInstallerAction(installer) {
        return installer.Update(this.progress)
    }
}
