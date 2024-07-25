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
		'signalClass'
	],
	#classVars : [
		'current'
	],
	#category : #'Iceberg-Git-CLI-Support'
}

{ #category : #accessing }
IceGitCliPlatform class >> current [
	^ current ifNil: [ current := self new ]
]

{ #category : #accessing }
IceGitCliPlatform >> config [
	^ self dummyInstance config
]

{ #category : #accessing }
IceGitCliPlatform >> dummyInstance [
	^ self repositoryClass new
		location: FileLocator home;
		yourself
]

{ #category : #accessing }
IceGitCliPlatform >> gitExecutable [
	^ gitExecutable
]

{ #category : #accessing }
IceGitCliPlatform >> gitExecutable: anExecutablePath [
	gitExecutable := anExecutablePath
]

{ #category : #accessing }
IceGitCliPlatform >> gitVersion [
	^ self dummyInstance gitVersion
]

{ #category : #initialization }
IceGitCliPlatform >> initialize [
	super initialize.
	self gitExecutable: 'git'
]

{ #category : #accessing }
IceGitCliPlatform >> repositoryClass [
	^ IceGitCliRepository
]

{ #category : #accessing }
IceGitCliPlatform >> signalClass [
	^ signalClass
]

{ #category : #accessing }
IceGitCliPlatform >> signalClass: aClass [
	signalClass := aClass
]
