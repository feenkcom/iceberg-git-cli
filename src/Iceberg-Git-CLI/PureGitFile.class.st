"
I represent a specific file in a repository, defined by a relative path string.
"
Class {
	#name : #PureGitFile,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'path'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitFile >> analyze [
	| extendedFileCommits first |
	extendedFileCommits := self log collect: [ :each |
		PureGitExtendedFileCommit new
			commit: each;
			changesToParent;
			yourself ].
	extendedFileCommits := extendedFileCommits toArray wait reverse.
	first := true.
	extendedFileCommits overlappingPairsDo: [ :parent :each |
		first ifTrue: [
			parent initializeAsFirst.
			first := false ].
		each initializeFromParent: parent ].
	^ extendedFileCommits
]

{ #category : #accessing }
PureGitFile >> fileReference [
	^ self repository location / self path
]

{ #category : #accessing }
PureGitFile >> log [
	^ (self repository logFrom: 'HEAD' for: self path)
		collect: [ :each |
			PureGitFileCommit new
				copyFrom: each;
				path: self path;
				yourself ]
]

{ #category : #accessing }
PureGitFile >> path [
	^ path
]

{ #category : #accessing }
PureGitFile >> path: aPathString [
	path := aPathString
]

{ #category : #printing }
PureGitFile >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(; nextPutAll: self path; nextPut: $)
]
