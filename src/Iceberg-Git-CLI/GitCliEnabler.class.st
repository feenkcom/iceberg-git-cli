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

{ #category : #accessing }
GitCliEnabler >> example [
	<gtExample>
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

	| platform repositories |

	platform := IceGitCliPlatform current.

	"throw an assertion failure when no suitable git is found"
	platform validateGit.
	"throw an assertion failure when git is not properly configured"
	platform validateGitSetup.

	platform install.

	repositories := IceRepository registry
		collect: [ :repository | 
			repository isGitCliRepository
				ifTrue: [ repository ]
				ifFalse: [ | newRepository |
					newRepository := IceGitCliRepository fromLibGitRepository: repository.
					repository gtRelease.
					newRepository headCommit resetFileSystem.
					newRepository ] ].

	IceRepository registry
		removeAll;
		addAll: repositories.

	self announceRepositoryRegistryModified
]

{ #category : #operations }
GitCliEnabler >> switchRepositoryImplementation: repository [
	^ GtIceRepositorySwitcher new switch: repository name
]
