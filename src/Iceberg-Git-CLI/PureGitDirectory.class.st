"
I represent a specific directory in a repository, defined by a relative path string.
"
Class {
	#name : #PureGitDirectory,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'path'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitDirectory >> basename [
	^ self isRoot
		ifTrue: [ '' ]
		ifFalse: [ ($/ split: path) last ]
]

{ #category : #accessing }
PureGitDirectory >> children [
	| fileReference files directories |
	fileReference := self fileReference.
	files := fileReference files collect: [ :each |
		self repository resolveFileReference: each ].
	directories := fileReference directories collect: [ :each |
		self repository resolveFileReference: each ].
	^ (directories sort: #path ascending) , (files sort: #path ascending)
]

{ #category : #accessing }
PureGitDirectory >> creationTime [
	^ self fileReference creationTime
]

{ #category : #accessing }
PureGitDirectory >> fileReference [
	^ self isRoot
		ifTrue: [ self repository location ]
		ifFalse: [ self repository location / self path ]
]

{ #category : #testing }
PureGitDirectory >> hasChildren [
	^ self fileReference hasChildren
]

{ #category : #initialization }
PureGitDirectory >> initialize [
	super initialize.
	path := ''
]

{ #category : #testing }
PureGitDirectory >> isDirectory [
	^ true
]

{ #category : #testing }
PureGitDirectory >> isEmpty [
	^ self hasChildren not
]

{ #category : #testing }
PureGitDirectory >> isFile [
	^ false
]

{ #category : #testing }
PureGitDirectory >> isRoot [
	^ path = ''
]

{ #category : #testing }
PureGitDirectory >> isTracked [
	^ false
]

{ #category : #accessing }
PureGitDirectory >> log [
	| commits |
	commits := self repository 
		logFrom: 'HEAD' 
		for: (self isRoot ifTrue: [ nil ] ifFalse: [ self path ]).
	^ commits collect: [ :each |
			PureGitFileCommit new
				copyFrom: each;
				path: self path;
				yourself ]
]

{ #category : #accessing }
PureGitDirectory >> parent [
	^ self isRoot
		ifTrue: [ self ]
		ifFalse: [ self repository resolveFileReference: self fileReference parent ]
]

{ #category : #accessing }
PureGitDirectory >> path [
	^ path
]

{ #category : #accessing }
PureGitDirectory >> path: aPathString [
	path := aPathString
]

{ #category : #printing }
PureGitDirectory >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(; nextPutAll: self path; nextPut: $)
]

{ #category : #accessing }
PureGitDirectory >> status [
	^ self repository statusFor: self path
]
