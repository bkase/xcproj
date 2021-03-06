import Foundation
import PathKit

// MARK: - PBXProj Extension (Getters)

extension PBXProj {
    
    /// Returns the file name from a build file reference.
    ///
    /// - Parameter buildFileReference: file reference.
    /// - Returns: build file name.
    func fileName(buildFileReference: String) -> String? {
        guard let buildFile: PBXBuildFile = objects.buildFiles.getReference(buildFileReference),
              let fileReference = buildFile.fileRef else {
                return nil
        }
        return fileName(fileReference: fileReference)
    }

    /// Returns the file name from a file reference.
    ///
    /// - Parameter fileReference: file reference.
    /// - Returns: file name.
    func fileName(fileReference: String) -> String? {
        if let variantGroup: PBXVariantGroup = objects.variantGroups.getReference(fileReference) {
            return variantGroup.name
        } else if let group: PBXGroup = objects.groups.getReference(fileReference) {
            return group.name
        } else if let versionGroup: XCVersionGroup = objects.versionGroups.getReference(fileReference) {
            return versionGroup.name
        } else if let fileReference: PBXFileReference = objects.fileReferences.getReference(fileReference) {
            return fileReference.name ?? fileReference.path
        } else {
            return nil
        }
    }

    /// Returns the configNamefile reference.
    ///
    /// - Parameter configReference: reference of the XCBuildConfiguration.
    /// - Returns: config name.
    func configName(configReference: String) -> String? {
        return objects.buildConfigurations[configReference]?.name
    }
    
    /// Returns the build phase a file is in.
    ///
    /// - Parameter reference: reference of the file whose type will be returned.
    /// - Returns: String with the type of file.
    func buildPhaseType(buildFileReference: String) -> BuildPhase? {
        if objects.sourcesBuildPhases.contains(where: { _, val in val.files.contains(buildFileReference)}) {
            return .sources
        } else if objects.frameworksBuildPhases.contains(where: { _, val in val.files.contains(buildFileReference)}) {
            return .frameworks
        } else if objects.resourcesBuildPhases.contains(where: { _, val in val.files.contains(buildFileReference)}) {
            return .resources
        } else if objects.copyFilesBuildPhases.contains(where: { _, val in val.files.contains(buildFileReference)}) {
            return .copyFiles
        } else if objects.headersBuildPhases.contains(where: { _, val in val.files.contains(buildFileReference)}) {
            return .headers
        }
        return nil
    }
    
    /// Returns the build phase type from its reference.
    ///
    /// - Parameter reference: build phase reference.
    /// - Returns: string with the build phase type.
    func buildPhaseType(buildPhaseReference: String) -> BuildPhase? {
        if objects.sourcesBuildPhases.contains(reference: buildPhaseReference) {
            return .sources
        } else if objects.frameworksBuildPhases.contains(reference: buildPhaseReference) {
            return .frameworks
        } else if objects.resourcesBuildPhases.contains(reference: buildPhaseReference) {
            return .resources
        } else if objects.copyFilesBuildPhases.contains(reference: buildPhaseReference) {
            return .copyFiles
        } else if objects.shellScriptBuildPhases.contains(reference: buildPhaseReference) {
            return .runScript
        } else if objects.headersBuildPhases.contains(reference: buildPhaseReference) {
            return .headers
        }
        return nil
    }
    
    /// Get the build phase name given its reference (mostly used for comments).
    ///
    /// - Parameter buildPhaseReference: build phase reference.
    /// - Returns: the build phase name.
    func buildPhaseName(buildPhaseReference: String) -> String? {
        if objects.sourcesBuildPhases.contains(reference: buildPhaseReference) {
            return "Sources"
        } else if objects.frameworksBuildPhases.contains(reference: buildPhaseReference) {
            return "Frameworks"
        } else if objects.resourcesBuildPhases.contains(reference: buildPhaseReference) {
            return "Resources"
        } else if let copyFilesBuildPhase = objects.copyFilesBuildPhases.getReference(buildPhaseReference) {
            return  copyFilesBuildPhase.name ?? "CopyFiles"
        } else if let shellScriptBuildPhase = objects.shellScriptBuildPhases.getReference(buildPhaseReference) {
            return shellScriptBuildPhase.name ?? "ShellScript"
        } else if objects.headersBuildPhases.contains(reference: buildPhaseReference) {
            return "Headers"
        }
        return nil
    }

    /// Returns the build phase name a file is in (mostly used for comments).
    ///
    /// - Parameter reference: reference of the file whose type name will be returned.
    /// - Returns: the build phase name.
    func buildPhaseName(buildFileReference: String) -> String? {
        let type = buildPhaseType(buildFileReference: buildFileReference)
        switch type {
        case .copyFiles?:
            return objects.copyFilesBuildPhases.first(where: { _, val in val.files.contains(buildFileReference)})?.value.name ?? type?.rawValue
        default:
            return type?.rawValue
        }
    }

    /// Infers project name from Path and sets it as project name
    ///
    /// Project name is needed for certain comments when serialising PBXProj
    ///
    /// - Parameters:
    ///   - path: path to .xcodeproj directory.
    func updateProjectName(path: Path) {
        guard path.parent().extension == "xcodeproj" else {
            return
        }
        let projectName = path.parent().lastComponentWithoutExtension
        let rootProject = objects.projects.getReference(rootObject)
        rootProject?.name = projectName
    }

}

// MARK: - PBXProj extension (Writable)

extension PBXProj: Writable {
    
    public func write(path: Path, override: Bool) throws {
        let encoder = PBXProjEncoder()
        let output = encoder.encode(proj: self)
        if override && path.exists {
            try path.delete()
        }
        try path.write(output)
    }
    
}

// MARK: - PBXProj Extension (UUID Generation)

public extension PBXProj {
    
    /// Returns a valid UUID for new elements.
    ///
    /// - Parameter element: project element class.
    /// - Returns: UUID available to be used.
    public func generateUUID<T: PBXObject>(for element: T.Type) -> String {
        var uuid: String = ""
        var counter: UInt = 0
        let random: String = String.random()
        let className: String = String(describing: T.self).hash.description
        repeat {
            counter += 1
            uuid = String(format: "%08X%08X%08X", className, random, counter)
        } while(objects.contains(reference: uuid))
        return uuid
    }
    
}
