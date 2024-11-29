"
IceGitCliPlatform supports the git CLI implementation.

You need the git executable in your path.

The following expression should work.

```
IceGitCliPlatform current gitVersion
```

The current required minimum version is 2.36

"
Class {
	#name : #IceGitCliPlatform,
	#superclass : #Object,
	#instVars : [
		'gitExecutable',
		'signalClass',
		'signCommits',
		'gitExecutableName',
		'announcer'
	],
	#classVars : [
		'current'
	],
	#category : #'Iceberg-Git-CLI-Support'
}

{ #category : #accessing }
IceGitCliPlatform class >> current [
	<gtExample>

	^ current ifNil: [ current := self new ]
]

{ #category : #accessing }
IceGitCliPlatform class >> reset [
	<gtExample>

	current := nil
]

{ #category : #accessing }
IceGitCliPlatform >> config [
	^ self dummyInstance config
]

{ #category : #accessing }
IceGitCliPlatform >> defaultGitExecutableName [
	^ 'git'
]

{ #category : #operations }
IceGitCliPlatform >> disableLogging [
	signalClass := nil
]

{ #category : #accessing }
IceGitCliPlatform >> dummyInstance [
	^ self repositoryClass new
		location: FileLocator home;
		yourself
]

{ #category : #operations }
IceGitCliPlatform >> enabledFullLogging [
	signalClass := GtGitCliSignal
]

{ #category : #accessing }
IceGitCliPlatform >> executor [
	^ IceGitCliExecutor new
]

{ #category : #accessing }
IceGitCliPlatform >> gitExecPath [
	^ (self dummyInstance runGitWithArgs: #('--exec-path')) first
]

{ #category : #accessing }
IceGitCliPlatform >> gitExecutable [
	^ gitExecutable ifNil: [ gitExecutable := self resolveGitPath pathString ]
]

{ #category : #accessing }
IceGitCliPlatform >> gitExecutable: anExecutablePath [
	gitExecutable := anExecutablePath
]

{ #category : #accessing }
IceGitCliPlatform >> gitExecutableName [
	^ gitExecutableName ifNil: [ gitExecutableName := self defaultGitExecutableName ]
]

{ #category : #accessing }
IceGitCliPlatform >> gitExecutableName: aNameString [
	gitExecutableName := aNameString
]

{ #category : #accessing }
IceGitCliPlatform >> gitVersion [
	^ self dummyInstance gitVersion
]

{ #category : #operations }
IceGitCliPlatform >> install [
	IceRepository repositoryClass: self repositoryClass
]

{ #category : #testing }
IceGitCliPlatform >> isInstalled [
	^ IceRepository repositoryClass = self repositoryClass
]

{ #category : #testing }
IceGitCliPlatform >> isLoggingEnabled [
	^ signalClass notNil
]

{ #category : #accessing }
IceGitCliPlatform >> repositoryClass [
	^ IceGitCliRepository
]

{ #category : #accessing }
IceGitCliPlatform >> resolveGitPath [
	^ GtOsSystemInfo current findExecutable: self gitExecutableName
]

{ #category : #accessing }
IceGitCliPlatform >> signCommits [
	^ signCommits ifNil: [ false ]
]

{ #category : #accessing }
IceGitCliPlatform >> signCommits: aBoolean [
	signCommits := aBoolean
]

{ #category : #accessing }
IceGitCliPlatform >> signalClass [
	^ signalClass
]

{ #category : #accessing }
IceGitCliPlatform >> signalClass: aClass [
	signalClass := aClass
]

{ #category : #operations }
IceGitCliPlatform >> uninstall [
	IceRepository repositoryClass: nil
]

{ #category : #operations }
IceGitCliPlatform >> validate [
	self validateGit.
	self validateGitSetup.
	self validateInstallation.
	^ true
]

{ #category : #operations }
IceGitCliPlatform >> validateGit [
	| gitVersionString gitVersion major minor |
	gitVersionString := [ self gitVersion ] on: Error do: [ nil ].
	self 
		assert: gitVersionString notNil 
		description: ('{1} not found, please install' format: { self gitExecutableName }).
	gitVersion := (Character space split: gitVersionString) third.
	major := ($. split: gitVersion) first asInteger.
	minor := ($. split: gitVersion) second asInteger.
	self
		assert: (major > 2 or: [ major = 2 and: [ minor >= 26 ] ])
		description: 'git version should be >= 2.26'.
	^ true
]

{ #category : #operations }
IceGitCliPlatform >> validateGitSetup [
	| config |
	config := self config.
	self
		assert: (config includesKey: 'user.name')
		description: 'git user.name not set'.
	self
		assert: (config includesKey: 'user.email')
		description: 'git user.email not set'.
	self signCommits
		ifTrue: [
			self
				assert: (config includesKey: 'user.signingkey')
				description: 'git user.signingkey not set'.
			"Let's require an explicit value for gpg.format even though 
			the default is openpgp when not set"
			self
				assert: (config includesKey: 'gpg.format')
				description: 'git gpg.format not set to one of ssh|x509|openpgp' ].
	^ true
]

{ #category : #operations }
IceGitCliPlatform >> validateInstallation [
	self 
		assert: self isInstalled 
		description: 'Iceberg-Git-CLI not installed, please evaluate `IceGitCliPlatform current install`'.
	^ true
]
