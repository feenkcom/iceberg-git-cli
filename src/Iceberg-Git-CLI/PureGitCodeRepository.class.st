"
I model a Pharo Smalltalk code repository where packages are stored in a soure directory in Tonel format
"
Class {
	#name : #PureGitCodeRepository,
	#superclass : #PureGitRepository,
	#instVars : [
		'srcDirectory'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #initialization }
PureGitCodeRepository >> initializeSrcDirectory [
	| project properties |
	project := self location / '.project' 
		readStreamDo: [ :stream | STON fromStream: stream ].
	srcDirectory := self location / (project at: #srcDirectory ifAbsent: [ 'src' ]).
	properties := srcDirectory / '.properties' 
		readStreamDo: [ :stream | STON fromStream: stream ].
	self assert: (properties at: #format) equals: #tonel
]

{ #category : #testing }
PureGitCodeRepository >> isCodeRepository [
	^ true
]

{ #category : #initialization }
PureGitCodeRepository >> location: aFileReference [
	super location: aFileReference.
	self initializeSrcDirectory
]

{ #category : #accessing }
PureGitCodeRepository >> packageNames [
	^ self srcDirectory directories collect: #basename
]

{ #category : #accessing }
PureGitCodeRepository >> packages [
	^ self packageNames collect: [ :each |
		(PureGitPackage inRepository:  self)
			name: each;
			yourself ]
]

{ #category : #accessing }
PureGitCodeRepository >> srcDirectory [
	^ srcDirectory
]

{ #category : #initialization }
PureGitCodeRepository >> srcDirectory: aFileReference [
	srcDirectory := aFileReference
]
