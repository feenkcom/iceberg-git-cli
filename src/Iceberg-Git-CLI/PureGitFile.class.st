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
	^ PureGitExtendedFileAnalysis new
		file: self;
		analyze
]

{ #category : #operations }
PureGitFile >> delete [
	self fileReference ensureDelete.
	"should we also delete empty parent directories as they do not exist in git ?"
	self repository announceRepositoryModified
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
