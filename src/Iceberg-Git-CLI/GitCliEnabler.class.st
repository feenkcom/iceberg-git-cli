"
I am a tool to enable the git cli implementation and to switch or restore all existing repositories' implementation.

I do a number of validations before enabling git cli, some assertions might fail.

You need the git command line executable installed, accessible, configured and working.

I rely on {{gtClass:IceGitCliPlatform}} for configuration details.

{{gtExample:GitCliEnabler>>#example|previewExpanded=true|previewHeight=500}}

{{gtExample:IceGitCliPlatform class>>#current|previewExpanded=true|previewHeight=500}}
"
Class {
	#name : #GitCliEnabler,
	#superclass : #Object,
	#category : #'Iceberg-Git-CLI-Support'
}

{ #category : #private }
GitCliEnabler >> announceRepositoryRegistryModified [
	Iceberg announcer announce: IceRepositoryRegistryModified
]

{ #category : #testing }
GitCliEnabler >> areAllRepositoriesSwitched [
	<gtExample>
	<return: #True>
	^ IceRepository registry allSatisfy: [ :each | each isGitCliRepository ]
]

{ #category : #accessing }
GitCliEnabler >> example [
	<gtExample>
	<return: #GitCliEnabler>
	
]

{ #category : #testing }
GitCliEnabler >> isValidGit [
	"Check if `git` can be found and has a recent enough version.
	Also check git configuration/setup."

	<gtExample>
	<return: #True>
	^ self platform isValidGit and: [ self platform isValidGitSetup ]
]

{ #category : #accessing }
GitCliEnabler >> platform [
	<gtExample>
	<return: #IceGitCliPlatform>
	^ IceGitCliPlatform current
]

{ #category : #operations }
GitCliEnabler >> revertAll [
	"Revert all existing repositories in the image to the old Libgit2 FFI implementation.
	Note: also defunct repositories are reverted."

	| repositories |

	IceRepository repositoryClass: IceLibgitRepository.

	repositories := IceRepository registry
		collect: [ :repository | 
			repository isGitCliRepository
				ifTrue: [ | newRepository |
					newRepository := IceLibgitRepository fromGitCliRepository: repository.
					repository gtRelease.
					newRepository ]
				ifFalse: [ repository ] ].

	IceRepository registry
		removeAll;
		addAll: repositories.

	self announceRepositoryRegistryModified
]

{ #category : #operations }
GitCliEnabler >> switchAll [
	"Switch all existing repositories in the image to the new Libgit-CLI implementation.
	Note: also defunct repositories are switched."

	| repositories |

	"throw an assertion failure when no suitable git is found"
	self platform validateGit.
	"throw an assertion failure when git is not properly configured"
	self platform validateGitSetup.
	
	self platform install.

	repositories := IceRepository registry
		collect: [ :repository | 
			repository isGitCliRepository
				ifTrue: [ repository ]
				ifFalse: [ | newRepository |
					newRepository := IceGitCliRepository fromLibGitRepository: repository.
					repository gtRelease.
					newRepository headCommit isNoCommit
						ifFalse: [ newRepository headCommit resetFileSystem ].
					newRepository ] ].

	IceRepository registry
		removeAll;
		addAll: repositories.

	self announceRepositoryRegistryModified
]

{ #category : #operations }
GitCliEnabler >> switchAllIfValidGit [
	self isValidGit ifTrue: [ self switchAll ]
]

{ #category : #operations }
GitCliEnabler >> switchRepositoryImplementation: repository [
	^ GtIceRepositorySwitcher new switch: repository name
]

{ #category : #operations }
GitCliEnabler >> writeStartupFile [
	"Write out a script that will be picked up by StartupPreferencesLoader in the image directory.
	In it, we enable commit signing (this is optional) and switch over all repositories to git cli.
	Once the image is saved in this state, these actions become a no op."
	
	FileSystem workingDirectory / StartupPreferencesLoader startupScriptName
		writeStreamDo: [ :out | 
			(ZnCrPortableWriteStream on: out)
				nextPutAll: 'IceGitCliPlatform current signCommits: true.
GitCliEnabler new switchAll.
(''{1} startup.st loaded & executed successfully'' format: { ZTimestamp now }) crTrace.
' ]
]
